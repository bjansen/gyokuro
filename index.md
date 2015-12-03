---
layout: default
---

<div class="hero-code">

<pre><code>shared void run() {
    get("/hello", (req, resp) => "Hello, World!");
    get("/users/:username", `showUser`);

    Application().run();
}

Template showUser(String username)
    => render("templates/user", map({"user" -> username}));</code></pre>

</div>

<hr>

## About gyokuro

gyokuro is a framework written in Ceylon, inspired by [Sinatra](http://www.sinatrarb.com/)
and [Spark](http://sparkjava.com/) for creating web applications with very few boilerplate.
It is based on the [Ceylon SDK](https://github.com/ceylon/ceylon-sdk) and uses `ceylon.net`.

With gyokuro, you can:

* declare *routes* that bind *paths* to simple `(Request, Response)` function *handlers*
* use *annotated classes* to group handlers together
* bind GET/POST parameters to function parameters instead of querying a `Request`
* serve *static assets* from a given directory

**Current version**: gyokuro has not been released yet, you can build it from sources.
Once the first version is released, gyokuro will be available on [Herd](https://herd.ceylon-lang.org).

## Getting started

gyokuro is still in development, so you have to build it from sources before using it:

* clone the project: `git clone https://github.com/bjansen/gyokuro.git`
* go to the cloned project: `cd gyokuro`
* build the project: `ceylon compile`
* copy the generated module to your local Ceylon repository to use it in other projects:
 `ceylon copy -o ~/.ceylon/repo com.github.bjansen.gyokuro` 
* create a new Ceylon project and import gyokuro:
^
    module com.example.mymodule "1.0.0" {
        import com.github.bjansen.gyokuro "0.1";
    }
  
* write your first application:
^
    shared void run {
        get("/hello", (req, resp) => "Hello, world!");
    
        Application().run();
    }

The above example will bootstrap a web server that runs by default on `0.0.0.0:8080`. The
path `/hello` will be bound to a handler that takes two parameters, a `Request` and a `Response`,
and returns a `String` containing `"Hello world"`. This string will be the response body.

## Documentation

The full documentation for the latest version (0.1.0) is available here:

<a href="{{ "/doc/0.1" | prepend: site.baseurl }}" class="button" id="doc-link"><span>Full documentation</span></a>

<br/>