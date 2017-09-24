---
layout: default
useToc: true
toc-start: 4
title: Application
---

{% include toc.md %}

## {{page.title}}

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
using a [RepositoryEndPoint](https://modules.ceylon-lang.org/repo/1/ceylon/net/1.3.3/module-doc/api/http/server/endpoints/RepositoryEndpoint.type.html).

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

Next: [annotated controllers](controllers).