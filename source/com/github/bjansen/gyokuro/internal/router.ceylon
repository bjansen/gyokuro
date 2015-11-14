import ceylon.collection {
	HashMap
}
import ceylon.language.meta.declaration {
	FunctionDeclaration
}
import ceylon.net.http {
	Method,
	get,
	post
}
import ceylon.net.http.server {
	Request,
	Response
}
import ceylon.language.meta.model {
	Function
}

shared object router {
	
	shared alias Handler => [Object?, FunctionDeclaration]|Callable<Anything,[Request, Response]>;
	
	value handlers = HashMap<[Method, String],Handler>();
	
	shared void registerRoute<Param>(String route, {Method+} methods,
		Function<Anything,Param>|Callable<Anything,[Request, Response]> handler)
			given Param satisfies Anything[] {
		
		for (method in methods) {
			if (is Function<> handler) {
				handlers.put([method, route], [null, handler.declaration]);
			} else {
				handlers.put([method, route], handler);
			}
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
