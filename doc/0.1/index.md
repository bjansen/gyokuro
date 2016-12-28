---
layout: default
useToc: true
---

# gyokuro 0.1
{:.no_toc}
This is the complete documentation for gyokuro 0.1.

* TOC
{:toc}

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
the [Ceylon specification](http://ceylon-lang.org/documentation/1.2/spec/html/lexical.html#identifiersandkeywords):
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
a [Request](https://modules.ceylon-lang.org/repo/1/ceylon/net/1.2.0-3/module-doc/api/http/server/Request.type.html)
and a [Response](https://modules.ceylon-lang.org/repo/1/ceylon/net/1.2.0-3/module-doc/api/http/server/Response.type.html)
 
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
[function model](https://modules.ceylon-lang.org/repo/1/ceylon/language/1.2.0/module-doc/api/meta/model/Function.type.html)
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
* uploaded files: `ceylon.net.http.server::UploadedFile`
* sequences of these types, like `[String+]` or `[Boolean*]`
* lists of these types, like `List<UploadedFile>`
 
Valid `Boolean` values are `true`, `false`, `0` and `1`.
 
In addition to binding request parameters by name, gyokuro can also inject "special parameters" by type:

* a `ceylon.net.http.server::Request`
* a `ceylon.net.http.server::Response`
* a [`com.github.bjansen.gyokuro::Flash`](https://github.com/bjansen/gyokuro/blob/master/source/com/github/bjansen/gyokuro/Flash.ceylon)

You can use any name you want for these:

    void myHandler(Request req, Response myResponse, Flash ahaaaa) {}
    get("/special", `myHandler`);

Finally, you can group handlers together in [**annotated controllers**](#annotated-controllers).

### Clearing routes

You can clear all the registered routes using `clearRoutes()`. This can come in handy during debug
sessions, or in unit tests.

## Logging

Before starting your application, it is a good idea to set up a logger, because gyokuro
logs useful information during startup (especially when it scans packages for annotations).
The preferred way do to this is to use
[ceylon.logging](https://modules.ceylon-lang.org/repo/1/ceylon/logging/1.2.0/module-doc/api/index.html):

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

Once routes are defined, you can start an application, which will run an embedded HTTP server
provided by `ceylon.net`. By default, the server will listen on `0.0.0.0:8080`, but you can use
other settings:

    Application {
        address = "127.0.0.1";
        port = 1337;
    }.run();  

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

### Filters

It is possible to declare **filters** that will be called for each new incoming request. Filters
are chained, and each filters returns a `Boolean` indicating if the next filter should be called.
If a filter returns `false`, it is its responsibility to modify the `Response` such as it
becomes valid and can be returned to the client. Filters are called in the order in which they are
passed to the `Application`.

    Boolean authenticationFilter(Request req, Response resp) {
        if (needsAuthentication(req)) {    
            resp.responseStatus = 401;
            resp.writeString("401 - Unauthorized. Please log in.");
            return false;
        }
        return true;
    }
    
    Application {
        filters = [authenticationFilter];
    }.run();


## Annotated controllers

<div class="gotcha" markdown="1">
As of 05/12/2015, there is [a bug in Ceylon IDE for Eclipse](https://github.com/ceylon/ceylon-ide-eclipse/issues/1627)
which can cause unexpected and silent errors, like annotated controllers not being scanned correctly.

If you clean-build your project and see errors like this:

<pre><code data-lang="none">the 'ExpressionVisitor' caused an exception visiting a 'Annotation'
node: '"java.lang.NullPointerException"'</code></pre>

then the recommended workaround is to compile your project from the CLI.
</div>

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

Controllers allow you to group related handlers together, and define a "hierarchy" of routes, 
because functions will inherit the path of their parent controller. In the above example, the full
paths will be `/users/:id` or `/users/`.

To declare a controller, create a class and annotate it with `controller`. Controllers don't have
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

gyokuro will scan the package `my.application.pkg` for annotated controller classes, and expose them
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

While gyokuro does not embed any templating engine, it provides an extension point that allows
you to plug your favorite engine. Extensions have to satisfy an interface named `TemplateRenderer`:

    shared interface TemplateRenderer {
        shared formal String render(String templateName,
                Map<String, Anything> context,
                Request req, Response resp);
    }

For example:

    shared object pebbleRenderer satisfies TemplateRenderer {
    
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