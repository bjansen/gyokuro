import net.gyokuro.core {
    render,
    Application,
    Template,
    get
}
import net.gyokuro.view.thymeleaf {
    ThymeleafRenderer
}
import ceylon.logging {
    defaultPriority,
    debug,
    addLogWriter,
    writeSimpleLog
}

"Run the module `gyokuro.demo.thymeleaf`."
shared void run() {
    defaultPriority = debug;
    addLogWriter(writeSimpleLog);
    
    get("/hello", `hello`);
    
    Application {
        renderer = ThymeleafRenderer("demos-assets/thymeleaf/", ".xhtml");
    }.run();
}

Template hello() => render("hello", map({ "who"->"World" }));
