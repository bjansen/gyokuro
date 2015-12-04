import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration,
	ValueDeclaration
}
import ceylon.net.http {
	AbstractMethod,
	get,
	post
}

"Declares a partial path associated to a class or a function.
 Routes declared on a class will be concatenated with its member
 routes.
 For example, the following code will result in a route `/foo/bar`:
 
     route(\"foo\")
     controller class MyController() {
         route(\"bar\")
         void hello() { }
     }
 "
shared annotation RouteAnnotation route(String path,
	{AbstractMethod+} methods = {get, post}) => RouteAnnotation(path, methods);

"The annotation class for the [[route]] annotation."
shared final annotation class RouteAnnotation(path, methods) 
		satisfies OptionalAnnotation<RouteAnnotation, FunctionDeclaration|ClassDeclaration> {
	
	shared String path;
	shared {AbstractMethod+} methods;
}

"Declares a class as a controller, allowing routes to be scanned."
see(`function route`)
shared annotation ControllerAnnotation controller() => ControllerAnnotation();

"The annotation class for the [[controller]] annotation."
shared final annotation class ControllerAnnotation()
		satisfies OptionalAnnotation<ControllerAnnotation, ClassDeclaration> {
	
}

"Declares that a handler parameter should be retrieved from the current
 HTTP session instead of GET/POST data. If no value can be retrieved from
 the session, a 400 response will be sent back to the client."
shared annotation SessionAnnotation session() => SessionAnnotation();

"The annotation class for the [[session]] annotation."
shared final annotation class SessionAnnotation()
        satisfies OptionalAnnotation<SessionAnnotation, ValueDeclaration> {
    
}
