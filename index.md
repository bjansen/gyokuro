---
layout: default
title: "gyokuro: a web framework for Ceylon"
---

<div class="hero-code dark">

<pre><code>shared void run() {
    get("/hello", (req, resp) => "Hello, World!");
    get("/users/:username", `showUser`);

    Application().run();
}

Template showUser(String username)
    => render("templates/user", map {"user" -> username});</code></pre>

</div>

<hr>

<div class="intro" markdown="1">
## Introducing gyokuro

gyokuro is a framework written in Ceylon, similar to [Sinatra](http://www.sinatrarb.com/)
and [Spark](http://sparkjava.com/) for creating web applications with very little boilerplate.
It is based on the [Ceylon SDK](https://github.com/ceylon/ceylon-sdk) and uses `ceylon.http.server`.
</div>

<div class="buttons">
    <a href="#getting-started" class="button getting-started"><span>Getting started</span></a>
    <a href="{{ "/doc/0.3" | prepend: site.baseurl }}" class="button doc-link"><span>Full documentation</span></a>
</div>

<div class="current-version" markdown="1">
**Current version**: [0.3 (Mar. 02, 2017)](https://herd.ceylon-lang.org/modules/net.gyokuro.core/0.3)
</div>

<hr>

<div class="hero-code with-text light" markdown="1">
<div markdown="1">
### Easy and type-safe bindings
Routes can be declared to bind paths to simple `(Request, Response)` function handlers.
You can also use references to functions with more complex signatures, and gyokuro will
automatically bind GET/POST/path parameters by name.

</div>
    get("/hello", (req, resp) => "Hello, World!");
    post("/user/edit/:id", `editUser`);

    void editUser(Integer id, String name, String password) {}
</div>

<div class="hero-code with-text" markdown="1">
    route("user")
    shared controller class UserController() {
        route("edit")
        shared void edit(Integer userId, String username) {}

        route("list")
        shared User[] listUsers() => ...
    }
<div markdown="1">
### Annotated controllers
In addition to the `get()` and `post()` functions, you can annotate classes or
objects with `controller`, allowing you to group multiple `route`s in the same 
declaration.

</div>
</div>

<div class="hero-code with-text light" markdown="1">
<div markdown="1">
### Templating
gyokuro does not ship with any particular templating engine, but it's very easy
to plug any existing engine via the [View API](https://modules.ceylon-lang.org/repo/1/net/gyokuro/view/api/0.3/module-doc/api/index.html).
Handlers don't need to be aware of which templating engine is used, they simply call the `render`
function with a template name and a context map.

</div>
    Template greet(String who) 
            => render("greetingTpl", map {"name" -> who});
    
    // Sample template renderer
    object helloRenderer satisfies TemplateRenderer {
        render(Template template, Map<String,Anything> context, 
                Request req, Response resp)
                => resp.write("Hello, ``context.get("name") else "world"``!");
    }
</div>

<p></p>

### Wait, there's more!

For a complete description of gyokuro's features, head off to the [docs](/docs/0.3), or keep
reading to get you started on a new project!

<hr>

## Getting started

* if you haven't already done so, grab a copy of the current 
[Ceylon distribution](https://ceylon-lang.org/download/) or a plugin for your favorite IDE  
* create a new Ceylon project and import gyokuro:
^
    module com.example.mymodule "1.0.0" {
        import net.gyokuro.core "0.3";
    }
  
* write your first application:
^
    shared void run() {
        get("/hello", (req, resp) => "Hello, world!");
    
        Application().run();
    }

The above example will bootstrap a web server that runs by default on `0.0.0.0:8080`. The
path `/hello` will be bound to a handler that takes two parameters, a `Request` and a `Response`,
and returns a `String` containing `"Hello world"`. This string will be the response body.

### Running examples

The [GitHub repository](https://github.com/bjansen/gyokuro/tree/master/demos/gyokuro/demo) contains
a few examples that show how to use gyokuro. You can run them very easily with the following commands:

* `git clone https://github.com/bjansen/gyokuro.git`
* `cd gyokuro`
* `./ceylonb`
* `./ceylonb compile`
* `./ceylonb run gyokuro.demo.rest`

### Livin' on the edge

gyokuro is still in development, so if you want to test the very latest bleeding edge version,
you can build it from sources:

* clone the project: `git clone https://github.com/bjansen/gyokuro.git`
* go to the cloned project: `cd gyokuro`
* build the project: `ceylon compile`
* copy the generated module to your local Ceylon repository to use it in other projects:
 `ceylon copy -o ~/.ceylon/repo net.gyokuro.core` 
* enjoy

## Documentation

The full documentation for the latest version (0.3) is available here:

<div class="buttons">
    <a href="{{ "/doc/0.3" | prepend: site.baseurl }}" class="button doc-link"><span>Full documentation</span></a>
</div>

The full documentation for the development version (0.4-SNAPSHOT) is 
<a href="{{ "/doc/0.4" | prepend: site.baseurl }}">also available</a>.

## Performance

See the [performance tests](perfs/) page.