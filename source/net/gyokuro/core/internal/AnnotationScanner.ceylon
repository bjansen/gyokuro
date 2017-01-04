import ceylon.http.common {
    AbstractMethod
}
import ceylon.language.meta {
    annotations,
    classDeclaration
}
import ceylon.language.meta.declaration {
    FunctionDeclaration,
    Package,
    ClassDeclaration,
    ValueDeclaration
}
import ceylon.logging {
    logger
}

import net.gyokuro.core {
    ControllerAnnotation,
    RouteAnnotation
}

shared object annotationScanner {
    
    value log = logger(`module`);

    shared alias Consumer => Anything(String, [Object, FunctionDeclaration], {AbstractMethod+});
    
    "Looks for controller definitions in the given [[controllers]].
     Scanned controllers and routes will be registered in the [[router]]
     for GET and POST methods."
    shared void scanControllers(String contextRoot, Package|{Object*} controllers,
        Consumer consumer = router.registerControllerRoute) {

        <ClassDeclaration|ValueDeclaration -> Anything>[] members;

        if (is Package controllers) {
            members = [ for (member in controllers.members<ClassDeclaration|ValueDeclaration>())
                        member -> null];
            log.trace("Scanning members in package ``controllers.name``");
        } else {
            members = [ for (o in controllers)
                        classDeclaration(o) -> o ];
            log.trace("Scanning members in existing instances");
        }

        for (member -> possibleInstance in members) {
            if (exists controller = annotations(`ControllerAnnotation`, member)) {
                log.trace("Scanning member ``member.name``");
                
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
                if (exists possibleInstance) {
                    instance = possibleInstance;
                } else if (is ClassDeclaration member) {
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
