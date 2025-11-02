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

  {%- assign category_pages = site.pages | where: "taxonomy_type", "category" -%}
  {%- assign category_entries = '' | split: '' -%}

  {%- for post in site.posts -%}
    {%- assign seen_slugs = '' | split: '' -%}
    {%- for term in post.categories -%}
      {%- assign slug = term | slugify: 'latin' -%}
      {%- unless seen_slugs contains slug -%}
        {%- assign seen_slugs = seen_slugs | push: slug -%}
        {%- capture entry_json -%}{"slug":"{{ slug }}","label":{{ term | jsonify }}}{%- endcapture -%}
        {%- assign entry = entry_json | from_json -%}
        {%- assign category_entries = category_entries | push: entry -%}
      {%- endunless -%}
    {%- endfor -%}
  {%- endfor -%}

  {%- assign grouped_categories = category_entries | group_by: "slug" -%}

  {%- capture category_map_json -%}
  {
  {%- for group in grouped_categories -%}
    {%- assign slug = group.name -%}
    {%- assign matching_pages = category_pages | where: "taxonomy_slug", slug -%}
    {%- assign preferred_page = matching_pages | first -%}
    {%- if preferred_page -%}
      {%- assign preferred_label = preferred_page.taxonomy_term | default: preferred_page.title -%}
    {%- else -%}
      {%- assign labels = group.items | map: "label" | uniq -%}
      {%- assign preferred_label = labels | sort_natural | first -%}
    {%- endif -%}
    {%- assign count = group.items | size -%}
    "{{ slug }}": {
      "slug": "{{ slug }}",
      "label": {{ preferred_label | jsonify }},
      "count": {{ count }}
    }{%- unless forloop.last -%},{%- endunless -%}
  {%- endfor -%}
  }
  {%- endcapture -%}

  {%- assign category_map = category_map_json | from_json -%}
  {%- assign category_list = '' | split: '' -%}
  {%- for pair in category_map -%}
    {%- assign data = pair[1] -%}
    {%- assign category_list = category_list | push: data -%}
  {%- endfor -%}
  {%- assign sorted_categories = category_list | sort_natural: "label" -%}

  {%- if sorted_categories and sorted_categories.size > 0 -%}
    <ul class="taxonomy-nav">
      {%- for category in sorted_categories -%}
        <li>
          <a class="button small outline" href="{{ '/category/' | append: category.slug | append: '/' | relative_url }}">
            {{ category.label }} <span class="taxonomy-count">({{ category.count }})</span>
          </a>
        </li>
      {%- endfor -%}
    </ul>
  {%- else -%}
    <p>Ainda não há categorias cadastradas.</p>
  {%- endif -%}
</section>
