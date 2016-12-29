---
layout: default
useToc: true
toc-start: 5
title: "Annotated controllers"
---

{% include toc.md %}

## {{page.title}}

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

Next: [flash attributes](flash).