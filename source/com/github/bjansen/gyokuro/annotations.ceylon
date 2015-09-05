import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration,
    ValueDeclaration
}

shared annotation RouteAnnotation route(String path) => RouteAnnotation(path);

shared final annotation class RouteAnnotation(path) 
		satisfies OptionalAnnotation<RouteAnnotation, FunctionDeclaration|ClassDeclaration> {
	
	shared String path;
}

shared annotation ControllerAnnotation controller() => ControllerAnnotation();

shared final annotation class ControllerAnnotation()
		satisfies OptionalAnnotation<ControllerAnnotation, ClassDeclaration> {
	
}

shared annotation SessionAnnotation session() => SessionAnnotation();

shared final annotation class SessionAnnotation()
        satisfies OptionalAnnotation<SessionAnnotation, ValueDeclaration> {
    
}
