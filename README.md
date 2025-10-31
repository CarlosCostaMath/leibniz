# Leibniz Blog

Site estático construído com [Jekyll](https://jekyllrb.com/) para hospedar o conteúdo do blog Leibniz. Este repositório reúne os layouts, componentes e conteúdos em português publicados em https://carloscostamath.github.io/leibniz.

## Como executar localmente

1. Instale Ruby (>= 3.1) e as gems `jekyll` e `bundler` (`gem install jekyll bundler`).
2. Dentro da pasta do projeto execute:
   ```bash
   jekyll serve --livereload --baseurl ""
   ```
   O `baseurl` vazio garante que os caminhos funcionem em `http://localhost:4000` mesmo que, em produção, o site rode sob `/leibniz`.
3. Gere a versão estática, quando necessário, com `jekyll build`.

## Estrutura essencial

```
_config.yml        → Configuração global (título, idioma, baseurl, paginação, plugins)
_data/navigation.yml → Itens do menu principal
_includes/         → Fragmentos reutilizáveis (componentes de post, breadcrumb, rodapé, intro da home)
_layouts/          → Layouts base (`default`) e de postagens (`post`)
_posts/            → Conteúdo publicado (arquivos `YYYY-MM-DD-titulo.md`)
assets/            → CSS, JS, fontes e SASS personalizados
images/            → Imagens utilizadas nas páginas e nos posts
category/, tag/    → Páginas dinâmicas para listar categorias e tags via JS
*.html, *.md na raiz → Páginas fixas (Início, Sobre, Contato, Arquivos, Tags, Categorias)
```

## Publicando conteúdo

- **Postagens:** salve arquivos Markdown em `_posts/` usando o padrão `YYYY-MM-DD-nome.md`. Utilize o front matter padrão:
  ```yaml
  ---
  layout: post
  title: "Título do artigo"
  subtitle: "Subtítulo opcional"
  date: 2025-11-26 12:00:00 -0300
  featured: true            # exibe em destaque na home (o mais recente vence)
  hero_image: images/pasta/imagem.jpg
  hero_caption: "Legenda opcional"
  description: "Resumo exibido nos cards"
  author: Nome do autor
  reading_time: "X min de leitura"
  categories:
    - Nome da categoria
  tags:
    - Etiqueta
  ---
  ```
  - Use `<!--more-->` para definir o resumo manual de um post.
  - As imagens devem ficar em `images/` e ser referenciadas com caminhos relativos (`/images/...`).
  - Componentes especiais (boxes, timelines, galerias) estão em `_includes/post-boxes.html` e podem ser inseridos com `{% include post-boxes.html type="..." %}`.

- **Páginas estáticas:** arquivos `.md` ou `.html` na raiz utilizam `layout: default`. Configure `nav_section` e `permalink` no front matter para controlar o menu ativo. É possível adicionar estilos e scripts específicos via `extra_css` e `extra_js` (arrays de URLs relativos).

## Taxonomias e navegação

- O menu principal é definido em `_data/navigation.yml`.
- `categories.md`, `tags.md` e `archives.md` geram as páginas de índice. Os detalhes dinâmicos das categorias e tags são renderizados pelas páginas em `category/` e `tag/`, que consomem os dados pré-gerados pelo Jekyll.
- As categorias e tags dos posts alimentam automaticamente as páginas mencionadas; mantenha a grafia consistente para evitar duplicações involuntárias.

## Estilos, scripts e componentes

- `assets/css/main.css` e `assets/css/custom.css` centralizam o estilo global. Novas regras específicas podem ser adicionadas em arquivos dedicados e incluídas via `extra_css` no front matter.
- Scripts adicionais ficam em `assets/js/`. Para páginas que precisam de JS específico, liste os arquivos em `extra_js`.
- O rodapé e demais blocos recorrentes residem em `_includes/` (`footer.html`, `breadcrumb.html`, `home/intro.html`). Prefira editar esses fragmentos quando houver mudanças estruturais.

## Boas práticas editoriais

- Preencha sempre `description`, `author` e `reading_time` para manter a consistência dos cards e da experiência do leitor.
- Marque apenas um post como `featured` por vez; o destaque da home seleciona automaticamente o mais recente com essa flag.
- Otimize imagens antes de subir (formatos JPEG/WEBP recomendados) e mantenha nomes descritivos.
- Revise links externos adicionando `target="_blank"` e `rel="noopener"` quando apropriado.

