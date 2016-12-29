---
layout: default
useToc: true
toc-start: 1
title: "What's new in 0.3?"
---

# gyokuro 0.3-SNAPSHOT
{:.no_toc}
This is the complete documentation for gyokuro 0.3-SNAPSHOT.

{% include toc.md %}

## {{page.title}}

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

Next: [routes](routes).