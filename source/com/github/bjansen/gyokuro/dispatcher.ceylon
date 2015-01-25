import ceylon.language.meta.declaration {
	FunctionDeclaration,
	Package
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
			handler[1].memberInvoke(handler[0], [], resp);
		} else {
			resp.responseStatus = 404;
			resp.writeString("Not found");
		}
	}
}
