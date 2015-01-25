import ceylon.language.meta.declaration {
	FunctionDeclaration,
	Package,
	ValueDeclaration,
	FunctionOrValueDeclaration
}
import ceylon.net.http {
	post,
	get
}
import ceylon.net.http.server {
	Response,
	Request,
	Endpoint,
	startsWith
}

class RequestDispatcher(String contextRoot, Package|Object declaration) {
	
	Map<String, [Object, FunctionDeclaration]> handlers;

	switch(declaration) 
	case (is Package) {
		handlers = annotationScanner.scanControllersInPackage(contextRoot, declaration);
	}
	else {
		handlers = emptyMap;
	}
	
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

			func.memberInvoke(handler[0], [], *args);
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
			}
		}
		
		return null;
	}
}
