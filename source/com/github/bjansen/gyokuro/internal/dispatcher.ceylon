import ceylon.io.charset {
    utf8
}
import ceylon.language.meta {
    classDeclaration
}
import ceylon.language.meta.declaration {
    FunctionDeclaration,
    Package,
    ValueDeclaration,
    FunctionOrValueDeclaration,
    OpenUnion,
    OpenType
}
import ceylon.logging {
    logger
}
import ceylon.net.http {
    post,
    get,
    contentType
}
import ceylon.net.http.server {
    Response,
    Request,
    Endpoint,
    startsWith
}

import com.github.bjansen.gyokuro.json {
    jsonSerializer
}

import com.github.bjansen.gyokuro {
	SessionAnnotation
}

shared class RequestDispatcher(String contextRoot, Package declaration, Boolean(Request, Response) filter) {
	
	value log = logger(`module com.github.bjansen.gyokuro`);
	
	Map<String, [Object, FunctionDeclaration]> handlers;
	
	Converter[] converters = [primitiveTypesConverter];

	handlers = annotationScanner.scanControllersInPackage(contextRoot, declaration);
	
	shared Endpoint endpoint() {
		return Endpoint(startsWith(contextRoot), dispatch, {get, post});
	}
	
	"Dispatch the incoming request to the matching method."	
	void dispatch(Request req, Response resp) {
		if (!filter(req, resp)) {
			return;
		}

		value matchingHandlers = handlers.filter((String->[Object, FunctionDeclaration] element) => req.path.equals(element.key));

		if (exists firstHandler = matchingHandlers.first) {
			value handler = firstHandler.item;
			value func = handler[1];
			variable Anything[] args = [];
			
			try {
    			for (param in func.parameterDeclarations) {
    				value arg = bindParameter(param, req, resp);
    				
    				if (exists arg) {
    					args = args.withTrailing(arg);
    				} else if (param.defaulted) {
    					// TODO We can't retrieve the default value, so even if we can
    					// bind the next parameters, we can't use them in memberInvoke(),
    					// so we just abort here.
    					break;
    				} else if (isOptional(param)) {
    					args = args.withTrailing(null);
    				} else {
    					throw BindingException("Cannot bind parameter ``param.name``");
    				}
    			}
    		} catch (BindingException e) {
    			log.error("", e);
    			resp.responseStatus = 400;
    			resp.writeString("Bad request");
    			return;
    		}

            try {
                //func.memberApply(type(handler[0]), *typeArguments)
    			value result = func.memberInvoke(handler[0], [], *args);
                writeResult(result, resp);
            } catch (AssertionError|Exception e) {
                log.error("Invocation of ``func.qualifiedName`` threw an error:\n", e);
                resp.responseStatus = 500;
                resp.writeString("<html><head><title>Error</title></head><body>500 - Internal Server Error</body></html>");
            }
		} else {
			resp.responseStatus = 404;
			resp.writeString("Not found");
		}
	}
	
	Boolean isOptional(FunctionOrValueDeclaration param) {
		if (is OpenUnion paramType = param.openType, paramType.caseTypes.size == 2) {
            if (exists nullType = paramType.caseTypes.find((elem) => elem == `class Null`.openType)) {
				return true; 
			}
		}
		return false;
	}
	
	OpenType getNonOptionalType(FunctionOrValueDeclaration param) {
		assert(is OpenUnion paramType = param.openType);
		
		value nonOptionalType = paramType.caseTypes.find((elem) => elem != `class Null`.openType);
		
		assert(exists nonOptionalType);
		
		return nonOptionalType;
	}
	
	Anything? bindParameter(FunctionOrValueDeclaration param, Request req, Response resp) {
		if (is ValueDeclaration param) {
			if (param.openType == `interface Response`.openType) {
				return resp;
			} else if (param.openType == `interface Request`.openType) {
				return req;
			} else if (param.annotated<SessionAnnotation>()) {
				return bindSessionValue(param, req);
			} else {
				return bindRequestParameter(param, req);
			}
		}
		
		return null;
	}
	
	Anything? bindSessionValue(ValueDeclaration param, Request req) {
		if (exists val = req.session.get(param.name)) {
			value valType = classDeclaration(val).qualifiedName;
			
			if (valType == param.openType.string) {
				return val;
			} else if (is String val) {
				return convertParameter(val, param);
			} else {
				throw BindingException("Cannot bind parameter ``param.name`` from session: type ``valType`` cannot be assigned nor converted to ``param.openType``");
			}
		}
		return null;
	}
	
	Anything? bindRequestParameter(ValueDeclaration param, Request req) {
		if (exists requestParam = req.parameter(param.name)) {
			return convertParameter(requestParam, param);
		}
		
		return null;
	}

	Anything convertParameter(String requestParam, ValueDeclaration param) {
		value targetType = if (isOptional(param)) then getNonOptionalType(param) else param.openType;
		
		for (converter in converters) {
			if (converter.supports(targetType)) {
				return converter.convert(targetType, requestParam);
			}
		}
		
		throw BindingException("Cannot bind parameter ``param.name``: no converter found for type ``param.openType``");
	}

    void writeResult(Anything result, Response resp) {
        if (is Object result) {
            resp.addHeader(contentType("application/json", utf8));
            resp.writeString(jsonSerializer.serialize(result));
        }
    }
}

class BindingException(String? description = null, Throwable? cause = null) extends Exception(description, cause) {
}
