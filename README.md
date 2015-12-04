# gyokuro
A web framework written in Ceylon, which allows:

* routing GET/POST requests to simple `(Request, Response)` handlers
* creating annotated controllers containing more powerful handlers
* serving static assets (HTML, CSS, JS, ...) from a directory

gyokuro is based on the [Ceylon SDK](http://github.com/ceylon/ceylon-sdk), 
and uses `ceylon.net`'s server API.

## Creating a simple webapp

Create a new Ceylon module:

```ceylon
module gyokuro.demo.rest "1.0.0" {
	import com.github.bjansen.gyokuro "0.1.0";
	import ceylon.net "1.2.0-3";
}
```

Add a runnable top level function that bootstraps a gyokuro application:

```ceylon
import com.github.bjansen.gyokuro {
	Application,
	get,
	post,
	serve
}

"Run an HTTP server listening on port 8080, that will react to requests on /hello.
Static assets will be served from the `assets` directory."
shared void run() {

	// React to GET/POST requests using a basic handler
	get("/hello", void (Request request, Response response) {
		response.writeString("Hello yourself!");
	});
	
	// Shorter syntax that lets Ceylon infer types and lets gyokuro
	// write the response
	post("/hello", (request, response) => "You're the POST master!");

	value app = Application {
		assets = serve("assets");
	};
	
	app.run();
}
```

## Binding parameters

In addition to basic handlers, gyokuro allows you to bind GET/POST data
directly to function parameters, and return an object that represents your response:

```ceylon
shared void run() {
	// ...
	post("/hello", `postHandler`);
	// ...
}

"Advanced handlers have more flexible parameters, you're
 not limited to `Request` and `Response`, you can bind
 GET/POST values directly to handler parameters!
 The returned value will be written to the response."
String postHandler(Float float, Integer? optionalInt, String who = "world") {
	// `float` is required, `optionalInt` is optional and
	// `who` will be defaulted to "world" if it's not in POST data.
	return "Hello, " + who + "!\n";
}
```

GET/POST values are mapped by name and automatically converted to the correct type.
Note that optional types and default values are also supported!

## Using annotated controllers

In addition to `get` and `post` functions, gyokuro supports annotated controllers.
Using annotations, you can easily group related handlers in a same controller.

Let's see how it works on a simple example:

```ceylon
shared void run() {

	value app = Application {
		// You can use REST-style annotated controllers like this:
		controllers = bind(`package gyokuro.demo.rest`, "/rest");
	};
	
	app.run();
}
```

The package `gyokuro.demo.rest` will be scanned for classes annotated with `controller`.
Each function annotated with `route` will be mapped to the corresponding path. For example:

```ceylon
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
```

Will be mapped to `http://localhost:8080/rest/duck/talk`.

## Want to learn more?

See the [complete documentation](http://bjansen.github.io/gyokuro/doc/0.1/) for more info.

You can find examples in the [demos directory](https://github.com/bjansen/gyokuro/tree/master/demos/).

