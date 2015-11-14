import ceylon.language.meta {
	annotations
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	Package,
	ClassDeclaration
}
import ceylon.logging {
	Logger,
	logger
}

import com.github.bjansen.gyokuro {
	ControllerAnnotation,
	RouteAnnotation
}

shared object annotationScanner {
	
	Logger log = logger(`module com.github.bjansen.gyokuro`);
	
	"Looks for controller definitions in the given [[package|pkg]].
	 Scanned controllers and routes will be registered in the [[router]]
	 for GET and POST methods."
	shared void scanControllersInPackage(String contextRoot, Package pkg) {
		value members = pkg.members<ClassDeclaration>();
		
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
						router.registerControllerRoute(functionRoute, [instance, func]);
					}
				}
			}
		}
	}

	String buildRoute(String prefix, String suffix) {
		value stripped = suffix.startsWith("/")
				then suffix.spanFrom(1) else suffix;
		
		 if (prefix.endsWith("/")) {
		 	return prefix + stripped;
		 }
		 
		 return prefix + "/" + stripped;
	}
}