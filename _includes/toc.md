{% assign parts = page.path | split: '/' %}
{% assign all_titles = "" | split:"|" %}

{% for pg in site.pages %}
    {% assign parts2 = pg.path  | split: '/' %}

    {% if parts[0] == parts2[0] and parts[1] == parts2[1] %}
        {% assign key = pg.toc-start | append: '⋰' | append: pg.title | append: '⋰' | append: pg.url %}
        {% assign all_titles = all_titles | push: key %}
    {% endif %}
{% endfor %}

<div id="toc">
    <ul>
    {% assign sorted_titles = all_titles | sort %}
    {% for title in sorted_titles %}
        {% assign parts = title | split: "⋰" %}
        {% assign toc-start = page.toc-start | append: "" %}
        {% if parts[0] == toc-start %}
            </ul>
<div markdown="1">

* TOC
{:toc}

</div>
            <ul>
        {% else %}
            <li><a href="{{ parts[2] }}">{{ parts[0] }}.&nbsp;&nbsp;{{ parts[1] }}</a></li>
        {% endif %}
    {% endfor %}
    </ul>
</div>
