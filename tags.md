---
layout: default
nav_section: tags
title: Tags
permalink: /tags/
description: Navegue pela nuvem de tags para encontrar artigos relacionados aos assuntos que mais interessam.
extra_css:
  - /assets/css/taxonomy.css
---
{% include breadcrumb.html %}

<section class="page-section taxonomy-page" id="tags-page">
  <div class="inner">
    <header class="major taxonomy-header">
      <h1>{{ page.title }}</h1>
      {%- if page.description -%}
        <p class="dek">{{ page.description }}</p>
      {%- endif -%}
    </header>
  </div>

  {%- assign all_tags = site.tags | sort -%}

  {%- if all_tags and all_tags.size > 0 -%}
    <ul class="taxonomy-nav">
      {%- for t in all_tags -%}
        {%- assign name = t[0] -%}
        {%- assign slug = name | slugify -%}
        <li>
          <a class="button small outline"
             href="{{ '/tag/' | relative_url }}?t={{ slug }}">
            #{{ name }}
          </a>
        </li>
      {%- endfor -%}
    </ul>
  {%- else -%}
    <p>Ainda não há tags cadastradas.</p>
  {%- endif -%}
</section>
