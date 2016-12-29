---
layout: default
useToc: true
toc-start: 3
title: Logging
---

{% include toc.md %}

## {{page.title}}

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

Next: [application](application).