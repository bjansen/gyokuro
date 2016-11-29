import net.gyokuro.core {
    get,
    Application,
    serve,
    post
}
import net.gyokuro.transform.gson {
    GsonTransformer
}
import ceylon.logging {
    defaultPriority,
    trace,
    writeSimpleLog,
    addLogWriter
}

"Run the module `gyokuro.demo.gson`."
shared void run() {
    get("/bob", (req, resp) => Employee("Bob", 75049.4));
    post("/save", `saveEmp`);
    
    addLogWriter(writeSimpleLog);
    defaultPriority = trace;
    
    Application {
        transformers = [GsonTransformer()];
        assets = serve("demos-assets/gson");
    }.run();
}

class Employee(name, salary) {
    shared String name;
    shared Float salary;    
}

String saveEmp(Employee emp) => "Saved ``emp.name`` in DB";