---
layout: default
nav_section: categories
title: Categorias
permalink: /categories/
description: Encontre conteúdos por tema e descubra todas as publicações associadas a cada categoria.
extra_css:
  - /assets/css/taxonomy.css
---
{% include breadcrumb.html %}
<section class="page-section taxonomy-page" id="categories-page">
  <div class="inner">
    <header class="major taxonomy-header">
      <h1>{{ page.title }}</h1>
      {%- if page.description -%}
        <p class="dek">{{ page.description }}</p>
      {%- endif -%}
    </header>
  </div>

  {%- assign all_cats = site.categories | sort -%}

  {%- if all_cats and all_cats.size > 0 -%}
    <ul class="taxonomy-nav">
      {%- for c in all_cats -%}
        {%- assign name = c[0] -%}
        {%- assign slug = name | slugify -%}
        <li>
          <a class="button small outline"
             href="{{ '/categoria/' | append: slug | append: '/' | relative_url }}">
            {{ name }} <span class="taxonomy-count">({{ c[1].size }})</span>
          </a>
        </li>
      {%- endfor -%}
    </ul>
  {%- else -%}
    <p>Ainda não há categorias cadastradas.</p>
  {%- endif -%}
</section>
