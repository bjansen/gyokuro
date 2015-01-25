# gyokuro
A web framework written in Ceylon, which allows:

* creating controllers and routes using Spring-MVC-like annotations
* serving static assets (HTML, CSS, JS, ...)

## Creating a simple webapp

Create a new Ceylon module:

````
module gyokuro.demo.rest "1.0.0" {
	import com.github.bjansen.gyokuro "0.1";
	import ceylon.net "1.1.1";
}
````

Add a runnable top level function that bootstraps a gyokuro application:

````
import com.github.bjansen.gyokuro {
	Application
}

"Run an HTTP server listening on port 8080. REST controllers located in package `gyokuro.demo.rest`
 will be bound to the root context `/rest`. Static assets will be served from the `assets` directory."
shared void run() {
	value app = Application(8080, "/rest", `package gyokuro.demo.rest`);
	
	app.assetsPath = "assets";
	
	app.run();
}
````

The package `gyokuro.demo.rest` will be scanned for classes annotated with `controller`. Each function annotated with `route` will be mapped to the corresponding URL. For example:

````
import ceylon.net.http.server {
	Response
}
import com.github.bjansen.gyokuro {
	controller,
	route
}

route("duck")
controller class SimpleRestController() {
	
	route("talk")
	shared void makeDuckTalk(Response resp) {
		resp.writeString("Quack world!");
	}
}
````

Will be mapped to `http://localhost:8080/rest/duck/talk`.