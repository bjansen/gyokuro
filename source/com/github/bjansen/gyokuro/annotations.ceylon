import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration
}

shared annotation RouteAnnotation route(String path) => RouteAnnotation(path);

shared final annotation class RouteAnnotation(path) 
		satisfies OptionalAnnotation<RouteAnnotation, FunctionDeclaration> {
	
	shared String path;
}

shared annotation ControllerAnnotation controller() => ControllerAnnotation();

shared final annotation class ControllerAnnotation()
		satisfies OptionalAnnotation<ControllerAnnotation, ClassDeclaration> {
	
}