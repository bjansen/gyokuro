---
layout: default
useToc: true
toc-start: 7
title: Helpers
---

{% include toc.md %}

## {{page.title}}

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

Next: [templating](templating).