import ceylon.io.charset {
	utf8
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	Package,
	ValueDeclaration,
	FunctionOrValueDeclaration,
    OpenUnion
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
import ceylon.logging {
    logger
}

class RequestDispatcher(String contextRoot, Package declaration) {
	
	value log = logger(`module com.github.bjansen.gyokuro`);
	
	Map<String, [Object, FunctionDeclaration]> handlers;
	
	Converter[] converters = [primitiveTypesConverter];

	handlers = annotationScanner.scanControllersInPackage(contextRoot, declaration);
	
	shared Endpoint endpoint() {
		return Endpoint(startsWith(contextRoot), dispatch, {get, post});
	}
	
	"Dispatch the incoming request to the matching method."	
	void dispatch(Request req, Response resp) {
		value matchingHandlers = handlers.filter((String->[Object, FunctionDeclaration] element) => req.path.equals(element.key));

		if (exists firstHandler = matchingHandlers.first) {
			value handler = firstHandler.item;
			value func = handler[1];
			variable Anything[] args = [];
			
			for (param in func.parameterDeclarations) {
				value arg = bindParameter(param, req, resp);
				
				if (exists arg) {
					args = args.withTrailing(arg);
				} else if (param.defaulted) {
					// TODO
				} else if (isOptional(param)) {
					args = args.withTrailing(null);
				} else {
					throw Exception("Cannot bind parameter ``param.name``");
				}
			}

            try {
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
	
	Anything? bindParameter(FunctionOrValueDeclaration param, Request req, Response resp) {
		if (is ValueDeclaration param) {
			if (param.openType == `interface Response`.openType) {
				return resp;
			} else if (param.openType == `interface Request`.openType) {
				return req;
			} else {
				return bindRequestParameter(param, req);
			}
		}
		
		return null;
	}
	
	Anything? bindRequestParameter(ValueDeclaration param, Request req) {
		String? requestParam = req.parameter(param.name);
		
		if (exists requestParam) {
			return convertParameter(requestParam, param);
		}
		
		return null;
	}

	Anything convertParameter(String requestParam, ValueDeclaration param) {
		for (converter in converters) {
			if (converter.supports(param.openType)) {
				return converter.convert(param.openType, requestParam);
			}
		}
		
		throw Exception("Cannot bind parameter ``param.name``: no converter found for type ``param.openType``");
	}

    void writeResult(Anything result, Response resp) {
        if (is Object result) {
            resp.addHeader(contentType("application/json", utf8));
            resp.writeString(jsonSerializer.serialize(result));
        }
    }
}
