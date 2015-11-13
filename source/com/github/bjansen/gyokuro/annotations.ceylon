import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration,
    ValueDeclaration
}

"Declares a partial path associated to a class or a function.
 Routes declared on a class will be concatenated with its members
 routes.
 For example, the following code will result in a route `/foo/bar`:
 
     route(\"foo\")
     controller class MyController() {
         route(\"bar\")
         void hello() { }
     }
 "
shared annotation RouteAnnotation route(String path) => RouteAnnotation(path);

shared final annotation class RouteAnnotation(path) 
		satisfies OptionalAnnotation<RouteAnnotation, FunctionDeclaration|ClassDeclaration> {
	
	shared String path;
}

"Declares a class as a controller, allowing routes to be scanned."
see(`function route`)
shared annotation ControllerAnnotation controller() => ControllerAnnotation();

shared final annotation class ControllerAnnotation()
		satisfies OptionalAnnotation<ControllerAnnotation, ClassDeclaration> {
	
}

"Declares that a handler parameter should be retrieved from the current
 HTTP session instead of GET/POST data. If no value can be retrieved from
 the session, a 400 response will be sent back to the client."
shared annotation SessionAnnotation session() => SessionAnnotation();

shared final annotation class SessionAnnotation()
        satisfies OptionalAnnotation<SessionAnnotation, ValueDeclaration> {
    
}
