# Leibniz Blog

Site estático construído com [Jekyll](https://jekyllrb.com/) e com design base
[Massively](https://html5up.net/massively) por [HTML5 UP](https://html5up.net/) — 
[CC BY 3.0](https://html5up.net/license) para hospedar o conteúdo do blog Leibniz.
Este repositório reúne os layouts, componentes e conteúdos em português publicados em
https://carloscostamath.github.io/leibniz.

## Estrutura essencial

```
_config.yml        → Configuração global (título, idioma, baseurl, paginação, plugins)
_data/navigation.yml → Itens do menu principal
_includes/         → Fragmentos reutilizáveis (componentes de post, breadcrumb, rodapé, intro da home)
_layouts/          → Layouts base (`default`), de postagens (`post`) e o layout de taxonomias (`taxonomy`)
_posts/            → Conteúdo publicado (arquivos `YYYY-MM-DD-titulo.md`)
assets/            → CSS, JS, fontes e SASS personalizados
images/            → Imagens utilizadas nas páginas e nos posts
category/, tag/    → Páginas individuais de categorias e tags (geradas via `scripts/generate_taxonomy_pages.rb`)
*.html, *.md na raiz → Páginas fixas (Início, Sobre, Contato, Arquivos, Tags, Categorias)
```

## Taxonomias e navegação

- O menu principal é definido em `_data/navigation.yml`.
- `categories.md`, `tags.md` e `archives.md` geram as páginas de índice. As páginas individuais de cada tag e categoria vivem em `tag/<slug>/index.md` e `category/<slug>/index.md` e são mantidas pelo script `scripts/generate_taxonomy_pages.rb`.
  - Os links exibidos nos posts (`_layouts/post.html`) usam o filtro `slugify` do Liquid, correspondente ao algoritmo utilizado pelo script para montar os diretórios, garantindo que cada tag/categoria aponta para o arquivo correto.
- As categorias e tags dos posts alimentam automaticamente as páginas mencionadas; mantenha a grafia consistente para evitar duplicações involuntárias e para que os slugs sejam criados corretamente.

## Como atualizar posts existentes

1. Abra cada arquivo em `_posts/` e garanta que o front matter possua blocos `categories:` e/ou `tags:` com listas em YAML, por exemplo:

   ```yaml
   categories:
     - História da Lógica
   tags:
     - Leibniz
     - Lógica
   ```
2. Ajuste a grafia conforme necessário. O Jekyll criará automaticamente slugs a partir dos nomes (`História da Lógica` → `/category/historia-da-logica/`).
3. Execute `ruby scripts/generate_taxonomy_pages.rb` para atualizar/gerar os arquivos em `tag/` e `category/` com base nas taxonomias existentes.
4. Salve o arquivo e execute `bundle exec jekyll serve` (ou o comando de build usado no projeto). As novas páginas serão servidas automaticamente e os links existentes nos posts e nos índices passarão a apontar para o novo sistema.

## Script de geração de taxonomias

- O script `scripts/generate_taxonomy_pages.rb` lê o front matter de cada post em `_posts/`, identifica as categorias e tags cadastradas e cria/atualiza automaticamente os arquivos `category/<slug>/index.md` e `tag/<slug>/index.md`.
- Execute `ruby scripts/generate_taxonomy_pages.rb` sempre que criar ou editar posts com novas taxonomias para garantir que as páginas individuais sejam recriadas.
- O script também remove diretórios obsoletos quando uma tag ou categoria deixa de existir em qualquer post, evitando páginas órfãs.
- Os arquivos gerados possuem um aviso no conteúdo para reforçar que são mantidos automaticamente. Evite editá-los manualmente: ajuste o post ou o script conforme necessário.

## Estilos, scripts e componentes

- `assets/css/main.css` e `assets/css/custom.css` centralizam o estilo global. Novas regras específicas podem ser adicionadas em arquivos dedicados e incluídas via `extra_css` no front matter.
- Scripts adicionais ficam em `assets/js/`. Para páginas que precisam de JS específico, liste os arquivos em `extra_js`.
- O rodapé e demais blocos recorrentes residem em `_includes/` (`footer.html`, `breadcrumb.html`, `home/intro.html`). Prefira editar esses fragmentos quando houver mudanças estruturais.
