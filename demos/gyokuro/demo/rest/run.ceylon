import com.github.bjansen.gyokuro {
	Application,
	get,
	post,
    Template,
    render,
    TemplateRenderer,
	serve,
	bind
}
import ceylon.logging {
	addLogWriter,
	Priority,
	info,
	Category,
	defaultPriority,
	trace
}
import ceylon.net.http.server {
	Request,
	Response
}

shared void run() {
	
	configureLogger();
	
	// React to GET/POST requests using a basic handler
	get("/hello", void (Request request, Response response) {
		response.writeString("Hello yourself!");
	});
	
	// You can also use more advanced handlers
	post("/hello", `postHandler`);

	// And render templates
	get("/render", `renderingHandler`);

	value app = Application {
		// You can also use annotated controllers, if you're
		// a nostalgic Java developer ;-)
		controllers = bind(`package gyokuro.demo.rest`, "/rest");

		// And serve static assets
		assets = serve("assets");

		// You can use any template engine you want
		renderer = object satisfies TemplateRenderer {

			// this is a dummy template renderer
		    shared actual String render(String templateName, Map<String,Anything> context,
				Request req, Response resp) {
				
		    	variable value result = templateName;
		    	for (key -> val in context) {
		    		if (exists val) {
		    			result = result.replace(key, val.string);
					}
				}
				return result;
			}
		};
	};
	
	// By default, the server will be started on 0.0.0.0:8080
	app.run();
}

"Advanced handlers have more flexible parameters, you're
 not limited to `Request` and `Response`, you can bind
 GET/POST values directly to handler parameters!"
String postHandler(String who = "world") {
	// `who` will get its value from POST data, and will
	// be defaulted to "world".
	return "Hello, " + who + "!\n";
}

Template renderingHandler() {
	return render("foobar", map({"bar" -> "baz"}));
}

void configureLogger() {
	defaultPriority = trace;
	addLogWriter {
		void log(Priority p, Category c, String m, Throwable? e) {
			value print = p<=info
			then process.writeLine
			else process.writeError;
			print("[``system.milliseconds``] ``p.string`` ``m``");
			if (exists e) {
				printStackTrace(e, print);
			}
		}		
	};
}

