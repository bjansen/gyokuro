import ceylon.net.http.server {
	Request,
	Response
}
import ceylon.net.http {
	Method,
	get,
	post
}
import ceylon.language.meta.declaration {
	FunctionDeclaration
}
import ceylon.collection {
	HashMap
}

shared object router {
	
	shared alias Handler => [Object, FunctionDeclaration]|Callable<Anything, [Request, Response]>;
	
	value handlers = HashMap<[Method, String], Handler>();
	
	shared void registerRoute(String route, {Method+} methods, void handler(Request req, Response resp)) {
		for (method in methods) {
			handlers.put([method, route], handler);
		}
	}
	
	shared void registerControllerRoute(String route, [Object, FunctionDeclaration] controllerHandler) {
		handlers.put([get, route], controllerHandler);
		handlers.put([post, route], controllerHandler);
	}
	
	shared Boolean canHandlePath(String path) {
		return handlers.keys.find((k) => k[1] == path) exists;
	}
	
	shared Handler? routeRequest(Request request) {
		return handlers.get([request.method, request.path]);
	}
}