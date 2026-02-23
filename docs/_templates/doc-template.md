---
title: "{{ title }}"
last_updated: {{ last_updated }} # YYYY-MM-DD
tags: {{ tags }}
---

# {{ title }}

Brief summary: {{ summary }}

## When to use this doc

{{ when_to_use }}

{% if sections %}
{% for section in sections %}
## {{ section.title }}

{{ section.body }}
{% endfor %}
{% endif %}

## Related docs

{% for item in related_docs %}
- [{{ item.label }}]({{ item.href }})
{% endfor %}
