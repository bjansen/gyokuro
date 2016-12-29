---
layout: default
useToc: true
toc-start: 6
title: "Flash attributes"
---

{% include toc.md %}

## {{page.title}}

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

Next: [helpers](helpers).