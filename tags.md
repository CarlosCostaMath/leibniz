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
  <!-- Seção: Cabeçalho de tags -->
  <div class="inner">
    <header class="major taxonomy-header">
      <h1>{{ page.title }}</h1>
      {%- if page.description -%}
        <p class="dek">{{ page.description }}</p>
      {%- endif -%}
    </header>
  </div>

  {%- assign tag_pages = site.pages | where: "taxonomy_type", "tag" -%}
  {%- assign tag_entries = '' | split: '' -%}

  {%- for post in site.posts -%}
    {%- assign seen_slugs = '' | split: '' -%}
    {%- for term in post.tags -%}
      {%- assign slug = term | slugify: 'latin' -%}
      {%- unless seen_slugs contains slug -%}
        {%- assign seen_slugs = seen_slugs | push: slug -%}
        {%- capture entry_json -%}{"slug":"{{ slug }}","label":{{ term | jsonify }}}{%- endcapture -%}
        {%- assign entry = entry_json | from_json -%}
        {%- assign tag_entries = tag_entries | push: entry -%}
      {%- endunless -%}
    {%- endfor -%}
  {%- endfor -%}

  {%- assign grouped_tags = tag_entries | group_by: "slug" -%}

  {%- capture tag_map_json -%}
  {
  {%- for group in grouped_tags -%}
    {%- assign slug = group.name -%}
    {%- assign matching_pages = tag_pages | where: "taxonomy_slug", slug -%}
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

  {%- assign tag_map = tag_map_json | from_json -%}
  {%- assign tag_list = '' | split: '' -%}
  {%- for pair in tag_map -%}
    {%- assign data = pair[1] -%}
    {%- assign tag_list = tag_list | push: data -%}
  {%- endfor -%}
  {%- assign sorted_tags = tag_list | sort_natural: "label" -%}

  {%- if sorted_tags and sorted_tags.size > 0 -%}
    <ul class="taxonomy-nav">
      {%- for tag in sorted_tags -%}
        <li>
          <a class="button small outline" href="{{ '/tag/' | append: tag.slug | append: '/' | relative_url }}">
            #{{ tag.label }} <span class="taxonomy-count">({{ tag.count }})</span>
          </a>
        </li>
      {%- endfor -%}
    </ul>
  {%- else -%}
    <p>Ainda não há tags cadastradas.</p>
  {%- endif -%}
</section>
