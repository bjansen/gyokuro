import ceylon.language.meta {
    annotations
}
import ceylon.language.meta.declaration {
    FunctionDeclaration,
    Package,
    ClassDeclaration,
    ValueDeclaration
}
import ceylon.logging {
    Logger,
    logger
}

import net.gyokuro.core {
    ControllerAnnotation,
    RouteAnnotation
}
import ceylon.http.common {
    AbstractMethod
}

shared object annotationScanner {
    
    Logger log = logger(`module net.gyokuro.core`);
    
    shared alias Consumer => Anything(String, [Object, FunctionDeclaration], {AbstractMethod+});
    
    "Looks for controller definitions in the given [[package|pkg]].
     Scanned controllers and routes will be registered in the [[router]]
     for GET and POST methods."
    shared void scanControllersInPackage(String contextRoot, Package pkg,
        Consumer consumer = router.registerControllerRoute) {
        
        value members = pkg.members<ClassDeclaration|ValueDeclaration>();
        log.trace("Scanning members in package ``pkg.name``");
        
        for (member in members) {
            if (exists controller = annotations(`ControllerAnnotation`, member)) {
                log.trace("Scanning member ``member.name`` in package ``pkg.name``");
                
                String controllerRoute;
                
                if (exists route = annotations(`RouteAnnotation`, member)) {
                    controllerRoute = buildPath(contextRoot, route.path);
                } else {
                    controllerRoute = contextRoot;
                }

                value classDecl = if (is ClassDeclaration member)
                then member
                else member.objectClass;

                if (!exists classDecl) {
                    log.warn("Skipped non-object value ``member.qualifiedName``");
                    continue;
                }

                Object instance;
                if (is ClassDeclaration member) {
                    instance = member.classApply<Object,[]>()();
                }
                else {
                    assert(is Object val = member.get());
                    instance = val;
                }
                value functions = classDecl.memberDeclarations<FunctionDeclaration>();

                for (func in functions) {
                    if (exists route = annotations(`RouteAnnotation`, func)) {
                        value functionRoute = buildPath(controllerRoute, route.path);
                        
                        log.trace("Binding function ``func.name`` to path ``functionRoute``");
                        consumer(functionRoute, [instance, func], route.methods);
                    }
                }
            }
        }
    }
    
    String buildPath(String prefix, String suffix) {
        value stripped = suffix.startsWith("/")
                then suffix.spanFrom(1) else suffix;
        
        if (prefix.endsWith("/")) {
            return prefix + stripped;
        }
        
        return prefix + "/" + stripped;
    }
}
