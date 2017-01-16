---
layout: default
useToc: true
toc-start: 2
title: Routes
---

{% include toc.md %}

## {{page.title}}

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
    get("/hello/:who/:message", (req, resp)
        =>  "Message to ``req.parameter("who") else "John Doe"``: ``req.parameter("message") else "?"``");

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
* values stored in the session (see next section)

You can use any name you want for these:

    void myHandler(Request req, Response myResponse, Flash ahaaaa) {}
    get("/special", `myHandler`);

Finally, you can group handlers together in [**annotated controllers**](#annotated-controllers).

### Session parameters

It is possible to inject data stored in the HTTP session into parameters of a handler, using the `session` annotation:

    void editProfile(session String username) {}

If a parameter annotated `session` cannot be injected (the value is `null` or of the wrong type),
gyokuro will throw a "400" error.

Session parameters are equivalent to the following code:

    void editProfile(Request req) {
        value username = req.session.get("username");
        if (is String username) {
            // ...
        } else {
            halt(400);
        }
    }

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

Next: [logging](logging).