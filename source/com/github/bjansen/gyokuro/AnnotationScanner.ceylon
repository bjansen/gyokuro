import ceylon.language.meta {
	annotations
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	NestableDeclaration,
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
	
	shared HashMap<String, [Object, FunctionDeclaration]> scanControllersInPackage(Package pkg) {
		value members = pkg.members<NestableDeclaration>();
		value handlers = HashMap<String, [Object, FunctionDeclaration]>();
		
		log.trace("Scanning members in package ``pkg.name``");
		
		for (member in members) {
			if (is ClassDeclaration member) { 
				if (exists controller = annotations(`ControllerAnnotation`, member)) {
					log.trace("Scanning member ``member.name`` in package ``pkg.name``");
					
					value instance = member.classApply<Object, []>()();
					
					value functions = member.memberDeclarations<FunctionDeclaration>();

					for (func in functions) {
						if (exists route = annotations(`RouteAnnotation`, func)) {
							log.trace("Binding function ``func.name`` to route ``route.path``");
							
							handlers.put(route.path, [instance, func]);
						}
					}
				}
			}
		}
		
		return handlers;
	}

}