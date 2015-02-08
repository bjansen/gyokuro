import ceylon.language.meta.declaration {
	FunctionDeclaration,
	Package,
	ValueDeclaration,
	FunctionOrValueDeclaration,
	OpenType
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
import ceylon.io.charset { utf8 }
import com.github.bjansen.gyokuro.json { jsonSerializer }

class RequestDispatcher(String contextRoot, Package declaration) {
	
	Map<String, [Object, FunctionDeclaration]> handlers;

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
				} else {
					throw Exception("Cannot bind parameter ``param.name``");
				}
			}

			value result = func.memberInvoke(handler[0], [], *args);
            writeResult(result, resp);
		} else {
			resp.responseStatus = 404;
			resp.writeString("Not found");
		}
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
		if (param.openType == `class Integer`.openType) {
			return parseInteger(requestParam);
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
