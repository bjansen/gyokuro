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

object annotationScanner {
	
	shared HashMap<String, [Object, FunctionDeclaration]> scanControllersInPackage(Package pkg) {
		value members = pkg.members<NestableDeclaration>();
		value handlers = HashMap<String, [Object, FunctionDeclaration]>();
		
		print("Scanning members in package ``pkg.name``");
		
		for (member in members) {
			if (is ClassDeclaration member) { 
				if (exists controller = annotations(`ControllerAnnotation`, member)) {
					print("Scanning member ``member.name`` in package ``pkg.name``");
					
					value instance = member.classApply<Object, []>()();
					
					value functions = member.memberDeclarations<FunctionDeclaration>();
					
					for (func in functions) {
						print("Scanning function ``func.name``");
						
						if (exists route = annotations(`RouteAnnotation`, func)) {
							print("It handles route ``route.path``");
							
							handlers.put(route.path, [instance, func]);
						}
					}
				}
			}
		}
		
		return handlers;
	}

}