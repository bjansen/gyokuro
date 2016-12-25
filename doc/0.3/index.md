---
layout: default
useToc: true
---

# gyokuro 0.3-SNAPSHOT
{:.no_toc}
This is the complete documentation for gyokuro 0.3-SNAPSHOT.

* TOC
{:toc}

## What's new in 0.3?

### Backward incompatible changes

* filters have been reworked, their new signature is now:
^
    shared alias Filter => Anything(Request, Response, Anything(Request, Response));
  
The most important change is that each filter is now responsible for calling the next filter
in the chain. It is thus possible for a filter to do things *before* and *after* handlers have
been called:

    void myFilter(Request req, Response resp, Anything(Request, Response) next) {
        doStuffBefore();

        // You could even provide other instances of Request or Response!
        next(req, resp);
        
        doStuffAfter();
    }

### PATCH method

gyokuro now supports the [HTTP PATCH](https://tools.ietf.org/html/rfc5789) method, which
is “used to apply partial modifications to a resource”.

### Application.stop()

You can now stop the application by calling the `stop()` method. Any further attempt to restart it
will be blocked. Thank you [@xkr47](https://github.com/xkr47) for your contribution!

### Application status listener

The `run()` function now accepts a [Status](https://modules.ceylon-lang.org/repo/1/ceylon/http/server/1.3.1/module-doc/api/Status.type.html)
listener, that allows you to run code right after the application has been started (remember, `run()` is
a blocking operation 😀).

## Routes

The entry points for any gyokuro application are **routes**. A route consists of the
following three parts:

* a **path**, as used in URLs, such as `/hello`, `/customer/42/bills` or `/articles/:articleId`
* a **verb**: `get`, `post`, `put`, `options`, `head`, `delete`, `trace` or `connect`
* a **handler**, which is a function that will handle a request matching a path and verb

The simplest way to define a route is as follows:

    get("/hello", (req, resp) =>  "Hello, world!");

gyokuro provides functions for each verb, taking two parameters: the path and the handler.

### Paths

A path can be virtually any string, as long as it can be correctly handled by browsers.
The only validation that gyokuro does is checking for duplicate routes (same verb and equal paths).

Paths can contain **named parameters**:

    get("/hello/:who", (req, resp)
        =>  "Hello, ``req.parameter("who") else "John Doe"``!");

Named parameters start with a colon followed by a valid lowercase identifier as defined by
the [Ceylon specification](http://ceylon-lang.org/documentation/1.3/spec/html/lexical.html#identifiersandkeywords):
a lowercase letter or underscore followed by 0 or more letter, digit or underscore.

When gyokuro matches a route containing named parameters, their value is added as a parameter
of the `Request`, and can also be injected by name in handlers (see next section).

Duplicate routes are not allowed, for example:

    get("/hello/world", (req, resp) =>  "Hello world");
    // error, duplicate route:
    get("/hello/:who", (req, resp) =>  "Hello other");

This will throw an exception during startup. On the other hand, the following routes are not duplicates
because they use a different verb:

    get("/hello/world", (req, resp) =>  "Hello world");
    // valid, not a duplicate:
    post("/hello/:who", (req, resp) =>  "Hello other");
 
### Handlers
 
In their simplest forms, handlers are functions that take two parameters, 
a [Request](https://modules.ceylon-lang.org/repo/1/ceylon/net/1.3.1/module-doc/api/http/server/Request.type.html)
and a [Response](https://modules.ceylon-lang.org/repo/1/ceylon/net/1.3.1/module-doc/api/http/server/Response.type.html)
 
    String myHandler(Request req, Response resp) {
        return "Hello";
    }
    get("/hello", myHandler);

While this signature is adequate for trivial cases, gyokuro allows you to use functions that take any
number of parameters to inject GET/POST data by name:

    String login(String username, String password) {
        ...
    }
    post("/login", `login`);

In this case, gyokuro will try to find two parameters named `username` and `password` in the `Request`,
and automatically pass them to the handler. Note that the route is expecting a 
[function model](https://modules.ceylon-lang.org/repo/1/ceylon/language/1.3.1/module-doc/api/meta/model/Function.type.html)
instead of a simple reference to a function. This is because we need to inspect its signature in order
to bind parameters correctly.

You can use optional types and default values in your handlers:

    String bindEverything(Integer qty, String? what,
                          String but = "binding")
        => "I got ``qty`` ``what else "problems"``,
            but ``but`` ain't one.";

    get("/complain", `bindEverything`);
    
In this case, the handler can still be called if the submitted data contains only `qty`: `what` will be
`null`, and `but` will take its default value. If no value can be found for one of the parameters,
gyokuro will respond with the HTTP status code 400.

The following types are supported in handler signatures:

* "primitive" types: `String`, `Integer`, `Float` and `Boolean`
* uploaded files: `ceylon.http.server::UploadedFile`
* sequences of these types, like `[String+]` or `[Boolean*]`
* lists of these types, like `List<UploadedFile>`
 
Valid `Boolean` values are `true`, `false`, `0` and `1`.
 
In addition to binding request parameters by name, gyokuro can also inject "special parameters" by type:

* a `ceylon.http.server::Request`
* a `ceylon.http.server::Response`
* a [`net.gyokuro.core::Flash`](https://github.com/bjansen/gyokuro/blob/master/source/net/gyokuro/core/Flash.ceylon)

You can use any name you want for these:

    void myHandler(Request req, Response myResponse, Flash ahaaaa) {}
    get("/special", `myHandler`);

Finally, you can group handlers together in [**annotated controllers**](#annotated-controllers).

### Handler return types

In addition to `String`s, handlers can return instances of 
[ceylon.html](https://modules.ceylon-lang.org/repo/1/ceylon/html/1.3.1/module-doc/api/index.html) nodes
that will automatically be converted to Strings:

    get("/html", (req, resp) =>
        Html {
            Body {
                H1 { "hello" }
            };
        }
    );

You can also use external templating engines by returning a `Template`, see the 
[Templating](#templating) section.
 
### Clearing routes

You can clear all the registered routes using `clearRoutes()`. This can come in handy during debug
sessions, or in unit tests.

## Logging

Before starting your application, it is a good idea to set up a logger, because gyokuro
logs useful information during startup (especially when it scans packages for annotations).
The preferred way do to this is to use
[ceylon.logging](https://modules.ceylon-lang.org/repo/1/ceylon/logging/1.3.1/module-doc/api/index.html):

    import ceylon.logging { ... }
    
    shared void run() {
        addLogWriter(writeSimpleLog);
        defaultPriority = trace;
        
        ...
    }

This will result in the following logs:

<pre><code data-language="shell">$ ceylon run gyokuro.demo.rest
    [1449317571409] TRACE Scanning members in package gyokuro.demo.rest
    [1449317571414] TRACE Scanning member SimpleRestController in package gyokuro.demo.rest
    [1449317571429] TRACE Binding function makeDuckTalk to path /rest/duck/talk
    ...</code></pre>

## Application

### Starting an application

Once routes are defined, you can start an application, which will run an embedded HTTP server
provided by `ceylon.http.server`. By default, the server will listen on `0.0.0.0:8080`, but you can use
other settings:

    Application {
        address = "127.0.0.1";
        port = 1337;
    }.run();  

### Listening to status changes

The `run()` function is blocking, but if you want to run extra code when the application is started,
it is possible to use a listener that will react on the `started` event:

    import ceylon.http.server {
        Status,
        started
    }

    void listener(Status status) {
        if (status == started) {
            print("Application has been started");
        }
    }

    Application()
        .run(listener);

### Stopping an application

When you are done with an application, it is possible to stop it using the `stop()` method, which
needs to be called from another thread or a status listener, since `run()` is blocking. For example,
here is how we run unit tests in `test.net.gyokuro.core`:

    app.run((status) {
        if (status == started) {
            // ...test assertions here...
            app.stop();
        }
    });

### Static assets

Besides calling handlers, gyokuro can process a request by serving **static assets**:

    Application {
        assets = serve("assets", "/public");
    }.run();

With the above configuration, every request whose path starts with `/public` will be served with
a file contained in `assets`. For example, for the path `/public/css/style.css`, gyokuro will
return the file `assets/css/style.css` if it exists. Otherwise, it will respond with a 404.

Static assets can be considered as a special case of routes, therefore it is not possible to
have a route that starts with the same path as static assets:

    route("/public/hello", (req, resp) => "hello");
    
    Application {
        // ERROR, duplicates route "/public/hello"
        assets = serve("assets", "/public"); 
    }.run();

### Modules

In addition to static assets, gyokuro can also 
[serve Ceylon modules](http://ceylon-lang.org/blog/2016/02/15/ceylon-browser-again/) to the browser,
using a [RepositoryEndPoint](https://modules.ceylon-lang.org/repo/1/ceylon/net/1.3.1/module-doc/api/http/server/endpoints/RepositoryEndpoint.type.html).

    Application {
        modulesPath = "/modules"; 
    }.run();

### Filters

It is possible to declare **filters** that will be called for each new incoming request. Filters
are chained, and each filter is responsible for calling the next filter in the chain.
If a filter chooses to break the chain, it is its responsibility to modify the `Response` such as it
becomes valid and can be returned to the client. Filters are called in the order in which they are
passed to the `Application`.

    void authenticationFilter(Request req, Response resp, void next(Request req, Response resp)) {
        if (needsAuthentication(req)) {
            resp.responseStatus = 401;
            resp.writeString("401 - Unauthorized. Please log in.");
            return;
        }
        next(req, resp);
    }

    void loggingFilter(Request req, Response resp, void next(Request req, Response resp)) {
        logger.info(req.path);
        value before = system.milliseconds;
        next(req, resp);
        logger.info("Took ``system.milliseconds - before``ms");
    }
    
    Application {
        filters = [authenticationFilter, loggingFilter];
    }.run();

In the previous example, `loggingFilter` might not be called if `authenticationFilter` decides that
the request is not authorized. On the other hand, if we specify:

    Application {
        filters = [loggingFilter, authenticationFilter];
    }.run();

 `loggingFilter` *and* `authenticationFilter` will be called on each request.

## Annotated controllers

In addition to the routes we saw before, gyokuro allows you to define **annotated controllers**:

    route("/users")
    controller class UserController {
        route("/:id", {get})
        shared void showUser(Integer id) {}
        
        route("/:id", {post})
        shared void modifyUser(Integer id) {}
        
        route("/")
        shared void listUsers() {}
    }

    route("/admin")
    controller object adminController {
        route("/")
        shared void showAdminHomepage() {}
    }

Controllers allow you to group related handlers together, and define a "hierarchy" of routes, 
because functions will inherit the path of their parent controller. In the above example, the full
paths will be `/users/:id` or `/users/`.

To declare a controller, create a class or an object and annotate it with `controller`. Controllers don't have
to inherit a special class or interface. Controllers can be annotated with `route`, to define
a partial path. If no route is present, gyokuro will treat as `route("")` or `route("/")`.
Leading and trailing slashes are optional, and consecutive slashes will be merged:

    controller class Foo {
        // this will match "/"
        route("/") shared void foo() {}
    }
    
    route("/")
    controller class Foo {
        // this will match "/"
        route("/") shared void foo() {}
        
        // this will match "/foo" or "/foo/"
        route("foo") shared void foo2() {}

        // this will match "/" too, so it's a duplicate of foo
        route("") shared void foo3() {}
    }

Controller handlers must be annotated with `route`, otherwise they are ignored. They will inherit
their parent controller's route, if it exists. Controller handlers can have the same signature
as [regular handlers](#handlers).

Annotated controllers need to be scanned during the `Application` instantiation:

    Application {
        controllers = bind(`package my.application.pkg`, "/rest");
    }.run();

gyokuro will scan the package `my.application.pkg` for annotated controller classes and objects, and expose them
under the root context `/rest`. For the controller `UserController` defined above, this means
that the complete paths will be `/rest/users/:id` and `/rest/users/`.

## Flash attributes

Flash attributes are special values, stored in the session, that are automatically removed once you access
them. They are one-time messages that can for example survive a redirect:

    shared void logout(Flash flash) {
        logoutUser();
        flash.add("message", "You have been logged out");
        redirect("/");
    }
    
You can then access a flash object from a template:

{% raw %}
    {% if flash.peek("message") != null %}
        <div class="info">{{ flash.get("message") }}</div>
    {% endif %}
{% endraw %}

As soon as a value is retrieved from a flash object (using `get()`), it is removed from this object.

## Helpers

### halt()

You can interrupt your handler immediately using the `halt()` function:

    shared String findAuthor(Integer id) {
        return authorDao.findById(id)?.name
               else halt(404, "Author not found");
    }

In this case, if the author cannot be found, `halt()` will interrupt the handler, therefore
bypassing any return value, and gyokuro will return a `404` response containing the given body.

`halt()` can be used anywhere in the handler:

    shared void newAuthor(String name) {
        if (authorAlreadyExists(name)) {
            halt(500);
        }
        value author = ...
    }

<div class="gotcha" markdown="span">
  If your handler contains `try/catch` blocks, be aware that `halt()` throws an exception under
  the hood, so make sure you're not catching it.
</div>

### redirect()

The `redirect()` helper is very similar to `halt()`: it interrupts the current handler, and asks
the browser to redirect to another URL:

    shared void login(String username, String password) {
        if (connect(username, password)) {
            redirect("/");
        }
        // show the form again...
    }

Optionally, you can specify an HTTP code for the response. By default, it is `303` ("See other").

<div class="gotcha" markdown="span">
  Like its friend `halt()`, `redirect()` throws an exception to interrupt the handler, so
  `try` not to `catch` it 😉.
</div>

## Templating

While gyokuro does not embed its own templating engine, it provides an extension point that allows
you to plug your favorite engine. Extensions have to satisfy an interface named `TemplateRenderer`,
defined in the module `net.gyokuro.view.api`:

    "A wrapper for a template engine capable of rendering
    a template to a [[String]]."
    shared interface TemplateRenderer<in Template=String> {
        shared formal String render(
            "The template to be rendered."
            Template template,
            "A map of named values that can be used in the template."
            Map<String,Anything> context,
            "The HTTP request."
            Request req,
            "The HTTP response."
            Response resp);
    }

For example:

    shared object pebbleRenderer satisfies TemplateRenderer<> {
    
        value loader = FileLoader();
        value engine = PebbleEngine(loader);
        
        loader.suffix = ".pebble"; 

        shared actual String render(String templateName,
            Map<String,Anything> context, Request req, Response resp) {
            
            value tpl = engine.getTemplate(templateName);
            value writer = StringWriter();
            tpl.evaluate(writer, context);
            return writer.string;
        }
    }

To make gyokuro use this template renderer, you have to pass it to the `Application`:

    Application {
        renderer = pebbleRenderer;
    }.run();

Finally, to render templates, handlers can use `render()` to return an instance 
of a `Template`:

    Template hello() => render("views/hello");
    get("/hello", `hello`);

`render()` takes two parameters, a template name and an optional map of things (sometimes
called "model" or "context") that can be used to render the template.

### Existing Java renderers

gyokuro already supports a few popular Java template renderers:

* Mustache.java in module `net.gyokuro.view.mustache` 
* Pebble in module `net.gyokuro.view.pebble`
* Rythm in module `net.gyokuro.view.rythm`
* Thymeleaf in module `net.gyokuro.view.thymeleaf`

These modules can be found as [examples on GitHub](https://github.com/bjansen/gyokuro/tree/master/source/net/gyokuro/view),
but won't be published on Herd because they tie you to a specific version of the
actual templating engine.

If you want to add support for another Java engine, you can directly extend 
`JavaTemplateRenderer`, which automatically converts Ceylon collections to
Java collections compatible with most Java engines.