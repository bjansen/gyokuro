---
layout: default
useToc: true
toc-start: 8
title: Templating
---

{% include toc.md %}

## {{page.title}}

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
