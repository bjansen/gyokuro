import ceylon.language.meta {
	annotations
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	Package,
	ClassDeclaration
}
import ceylon.collection {
	HashMap
}
import ceylon.logging {
	Logger,
	logger
}

object annotationScanner {
	
	Logger log = logger(`module com.github.bjansen.gyokuro`);
	
	shared HashMap<String, [Object, FunctionDeclaration]> scanControllersInPackage(String contextRoot, Package pkg) {
		value members = pkg.members<ClassDeclaration>();
		value handlers = HashMap<String, [Object, FunctionDeclaration]>();
		
		log.trace("Scanning members in package ``pkg.name``");
		
		for (member in members) {
			if (exists controller = annotations(`ControllerAnnotation`, member)) {
				log.trace("Scanning member ``member.name`` in package ``pkg.name``");
				
				String controllerRoute;
				 
				if (exists route = annotations(`RouteAnnotation`, member)) {
					controllerRoute = buildRoute(contextRoot, route.path);
				} else {
					controllerRoute = contextRoot;
				}
				
				value instance = member.classApply<Object, []>()();
				
				value functions = member.memberDeclarations<FunctionDeclaration>();

				for (func in functions) {
					if (exists route = annotations(`RouteAnnotation`, func)) {
						value functionRoute = buildRoute(controllerRoute, route.path);

						log.trace("Binding function ``func.name`` to route ``functionRoute``");
						handlers.put(functionRoute, [instance, func]);
					}
				}
			}
		}
		
		return handlers;
	}

	String buildRoute(String prefix, String suffix) {
		 if (prefix.endsWith("/")) {
		 	return prefix + suffix;
		 }
		 
		 return prefix + "/" + suffix;
	}
}