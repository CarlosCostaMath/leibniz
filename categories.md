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
  <!-- Cabeçalho -->
  <div class="inner">
    <header class="major taxonomy-header">
      <h1>{{ page.title }}</h1>
      {%- if page.description -%}
        <p class="dek">{{ page.description }}</p>
      {%- endif -%}
    </header>
  </div>

  {%- comment -%}
    TENTATIVA 1 — usar o índice nativo do Jekyll:
    'site.categories' é um hash: [ [nome, [posts...]], ... ]
  {%- endcomment -%}
  {%- assign all_cats = site.categories | sort -%}

  {%- if all_cats and all_cats.size > 0 -%}
    <ul class="taxonomy-nav">
      {%- for c in all_cats -%}
        {%- assign name = c[0] -%}
        {%- assign posts = c[1] -%}
        {%- assign slug = name | slugify: 'latin' -%}
        <li>
          <a class="button small outline" href="{{ '/category/' | append: slug | append: '/' | relative_url }}">
            {{ name }} <span class="taxonomy-count">({{ posts | size }})</span>
          </a>
        </li>
      {%- endfor -%}
    </ul>

  {%- else -%}
    {%- comment -%}
      TENTATIVA 2 — fallback para páginas geradas pelo script (Codex):
      varremos site.pages com taxonomy_type: "category".
    {%- endcomment -%}
    {%- assign cat_pages = site.pages | where: "taxonomy_type", "category" -%}
    {%- assign sorted = cat_pages | sort: "taxonomy_slug" -%}

    {%- if sorted and sorted.size > 0 -%}
      <ul class="taxonomy-nav">
        {%- for p in sorted -%}
          <li>
            <a class="button small outline" href="{{ p.url | relative_url }}">
              {{ p.title }}
              {%- if p.posts -%}
                <span class="taxonomy-count">({{ p.posts | size }})</span>
              {%- endif -%}
            </a>
          </li>
        {%- endfor -%}
      </ul>
    {%- else -%}
      <p>Ainda não há categorias cadastradas.</p>
    {%- endif -%}
  {%- endif -%}
</section>
