import com.github.bjansen.gyokuro {
	Application,
	get,
	post
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
	
	value app = Application {
		// You can also use annotated controllers, if you're
		// a nostalgic Java developer ;-)
		restEndpoint = ["/rest", `package gyokuro.demo.rest`];

		// And serve static assets
		assetsPath = "assets";
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

