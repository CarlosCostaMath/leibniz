# Leibniz Blog

Site estático construído com [Jekyll](https://jekyllrb.com/) e com design base
[Massively](https://html5up.net/massively){:target="_blank" rel="noopener noreferrer"} por
[HTML5 UP](https://html5up.net/){:target="_blank" rel="noopener noreferrer"} — 
[CC BY 3.0](https://html5up.net/license){:target="_blank" rel="license noopener noreferrer"}
para hospedar o conteúdo do blog Leibniz. Este repositório reúne os layouts, componentes e
conteúdos em português publicados em <https://carloscostamath.github.io/leibniz>.

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

## Taxonomias e navegação

- O menu principal é definido em `_data/navigation.yml`.
- `categories.md`, `tags.md` e `archives.md` geram as páginas de índice. Os detalhes dinâmicos das categorias e tags são renderizados pelas páginas em `category/` e `tag/`, que consomem os dados pré-gerados pelo Jekyll.
- As categorias e tags dos posts alimentam automaticamente as páginas mencionadas; mantenha a grafia consistente para evitar duplicações involuntárias.

## Estilos, scripts e componentes

- `assets/css/main.css` e `assets/css/custom.css` centralizam o estilo global. Novas regras específicas podem ser adicionadas em arquivos dedicados e incluídas via `extra_css` no front matter.
- Scripts adicionais ficam em `assets/js/`. Para páginas que precisam de JS específico, liste os arquivos em `extra_js`.
- O rodapé e demais blocos recorrentes residem em `_includes/` (`footer.html`, `breadcrumb.html`, `home/intro.html`). Prefira editar esses fragmentos quando houver mudanças estruturais.
