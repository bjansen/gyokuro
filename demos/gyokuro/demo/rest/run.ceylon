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

"Run an HTTP server listening on port 8080.
 REST controllers located in package `gyokuro.demo.rest`will be
 bound to the root context `/rest`.
 Static assets will be served from the `assets` directory."
shared void run() {
	
	configureLogger();
	
	// React to GET/POST requests using a basic handler
	get("/hello", void (Request request, Response response) {
		response.writeString("Hello yourself!");
	});
	
	post("/hello", void (Request request, Response response) {
		response.writeString("You're the POST master!");
	});
	
	value app = Application {
		// You can also use REST-style annotated controllers
		restEndpoint = ["/rest", `package gyokuro.demo.rest`];

		// And serve static assets
		assetsPath = "assets";
	};
	
	app.run();
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

