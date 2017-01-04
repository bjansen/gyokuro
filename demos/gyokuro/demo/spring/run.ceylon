import ceylon.http.server {
    Response
}
import ceylon.interop.java {
    javaAnnotationClass
}
import ceylon.logging {
    trace,
    addLogWriter,
    writeSimpleLog,
    defaultPriority
}

import net.gyokuro.core {
    controller,
    route,
    Application,
    bind,
    ControllerAnnotation
}

import org.springframework.beans.factory.annotation {
    autowired
}
import org.springframework.context.annotation {
    AnnotationConfigApplicationContext
}
import org.springframework.stereotype {
    component
}

shared void run() {
    addLogWriter(writeSimpleLog);
    defaultPriority = trace;

    print("Scanning current package for Spring-annotated classes");
    value springContext = AnnotationConfigApplicationContext(`package`.qualifiedName);

    print("Starting gyokuro application");

    value controllerAnnotation = javaAnnotationClass<ControllerAnnotation>();
    value controllers = [*springContext.getBeansWithAnnotation(controllerAnnotation).values()];

    Application {
        // We provide our own controller instances instead of letting gyokuro scan a package
        controllers = bind(controllers);
    }.run();
}

"A gyokuro [[controller]] that will be instantiated by Spring."
component controller class MyController() {

    "Could also be injected in the parameter list:

         class MyController(autowired IService service)
    "
    late autowired IService service;

    route("/hello")
    shared void hello(Response resp, String who = "world") {
        resp.writeString(service.greet(who));
    }
}

interface IService {
    shared formal String greet(String who);
}

"A Spring bean defining a simple service."
component class Service() satisfies IService {
    greet(String who) => "Hello, ``who`` from a Spring service!";
}
