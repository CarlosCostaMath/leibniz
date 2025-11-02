---
layout: default
nav_section: archives
title: Arquivos
permalink: /archives/
description: Explore todas as publicações em ordem cronológica, agrupadas por ano.
extra_css:
  - /assets/css/taxonomy.css
---

{% include breadcrumb.html %}

<section id="archives-page" class="post taxonomy-page">
  <!-- Seção: Cabeçalho do arquivo -->
  <header class="major taxonomy-header">
    <h1>{{ page.title }}</h1>
    {%- if page.description -%}
      <p class="dek">{{ page.description }}</p>
    {%- endif -%}
  </header>

  {%- assign posts_by_year = site.posts
    | sort: 'date'
    | reverse
    | group_by_exp: 'post', "post.date | date: '%Y'" -%}

  <!-- Seção: Navegação por ano -->
  {%- if posts_by_year.size > 1 -%}
    <ul class="taxonomy-nav">
      {%- for year in posts_by_year -%}
        <li>
          <a href="#ano-{{ year.name }}" class="button small outline">{{ year.name }}</a>
        </li>
      {%- endfor -%}
    </ul>
  {%- endif -%}

  <!-- Seção: Listagem anual -->
  {%- if posts_by_year and posts_by_year.size > 0 -%}
    <div id="archives-container" class="archives-years">
      {%- for year in posts_by_year -%}
        <details id="ano-{{ year.name }}" class="year-card" {% if forloop.first %}open{% endif %}>
          <summary class="year-summary">
            <span class="year-title">{{ year.name }}</span>
            <span class="year-count">
              {%- assign total = year.items | size -%}
              ({{ total }})
            </span>
          </summary>

          <ul class="archive-list">
            {%- assign posts_for_year = year.items | sort: 'date' | reverse -%}
            {%- for post in posts_for_year -%}
              {%- assign thumb = post.cover | default: post.hero_image | default: '/images/pic02.jpg' -%}
              <li class="archive-item">
                <a class="archive-link" href="{{ post.url | relative_url }}">
                  <img class="thumb" src="{{ thumb | relative_url }}" alt="{{ post.title | default: 'Post' | escape}}">
                  <div class="meta">
                    <h3 class="archive-title">{{ post.title | default: "(Sem título)" }}</h3>
                    <time class="archive-date" datetime="{{ post.date | date_to_xmlschema }}">
                      {{ post.date | date: "%B %-d, %Y" }}
                    </time>
                  </div>
                </a>
              </li>
            {%- endfor -%}
          </ul>
        </details>
      {%- endfor -%}
    </div>
  {%- else -%}
    <p>Ainda não há publicações no arquivo.</p>
  {%- endif -%}
</section>
