import com.github.bjansen.gyokuro {
	Application
}
import ceylon.logging {
	addLogWriter,
	Priority,
	info,
	Category,
	defaultPriority,
	trace
}

"Run an HTTP server listening on port 8080. REST controllers located in package `gyokuro.demo.rest`
 will be bound to the root context `/rest`. Static assets will be served from the `assets` directory."
shared void run() {
	
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
	
	value app = Application(8080, "/rest", `package gyokuro.demo.rest`);
	
	app.assetsPath = "assets";
	
	app.run();
}
