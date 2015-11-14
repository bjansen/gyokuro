# gyokuro
A web framework written in Ceylon, which allows:

* creating controllers and routes using Spring-MVC-like annotations
* serving static assets (HTML, CSS, JS, ...)

## Creating a simple webapp

Create a new Ceylon module:

```ceylon
module gyokuro.demo.rest "1.0.0" {
	import com.github.bjansen.gyokuro "0.1";
	import ceylon.net "1.2.0";
}
```

Add a runnable top level function that bootstraps a gyokuro application:

```ceylon
import com.github.bjansen.gyokuro {
	Application,
	get,
	post
}

"Run an HTTP server listening on port 8080, that will react to requests on /hello.
Static assets will be served from the `assets` directory."
shared void run() {

	// React to GET/POST requests using a basic handler
	get("/hello", void (Request request, Response response) {
		response.writeString("Hello yourself!");
	});
	
	post("/hello", void (Request request, Response response) {
		response.writeString("You're the POST master!");
	});

	value app = Application {
		assetsPath = "assets";
	};
	
	app.run();
}
```

## Leveraging the power of annotated controllers

In addition to `get` and `post` functions, gyokuro also allows you to define annotated controllers.
Using annotations, you can easily group related route handlers in a same controller. These handlers
are also much more powerful than `void (Request, Response)` functions, because you can bind GET/POST
parameters directly to function parameters, and return an object that represents your response.

Let's see how it works on a simple example:

```ceylon
shared void run() {

	value app = Application {
		// You can use REST-style annotated controllers like this:
		restEndpoint = ["/rest", `package gyokuro.demo.rest`];
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

GET/POST parameters can easily be mapped to function parameters, with support for optional types and default values:

```ceylon
route("awesome")
shared void bindParameters(String string, Integer? int, Float float = 1.23) {
    // if `int` or `float` can't be found in GET/POST values, the function can still be called
}
```

## Want to learn more?

See the [wiki](https://github.com/bjansen/gyokuro/wiki) for more documentation.
