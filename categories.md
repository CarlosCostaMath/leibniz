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

  {%- assign cat_pages = site.pages | where: "taxonomy_type", "category" -%}
  {%- assign sorted = cat_pages | sort: "taxonomy_slug" -%}

  {%- if sorted and sorted.size > 0 -%}
    <ul class="taxonomy-nav">
      {%- for p in sorted -%}
        <li>
          <a class="button small outline" href="{{ p.url | relative_url }}">
            {{ p.taxonomy_term }}
            <span class="taxonomy-count">({{ p.posts | size }})</span>
          </a>
        </li>
      {%- endfor -%}
    </ul>
  {%- else -%}
    <p>Ainda não há categorias cadastradas.</p>
  {%- endif -%}
</section>
