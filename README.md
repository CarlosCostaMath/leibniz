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
category/, tag/    → Diretórios de categorias e tags; cada termo possui `index.md` gerado pelo script `scripts/generate_taxonomy_pages.rb`
*.html, *.md na raiz → Páginas fixas (Início, Sobre, Contato, Arquivos, Tags, Categorias)
```

## Taxonomias e navegação

- O menu principal é definido em `_data/navigation.yml`.
- `categories.md`, `tags.md` e `archives.md` geram as páginas de índice. As páginas individuais vivem em `category/<slug>/index.md` e `tag/<slug>/index.md`, produzidas pelo script `scripts/generate_taxonomy_pages.rb`.
  - Os links exibidos nos posts (`_layouts/post.html`) usam o filtro `slugify: 'latin'` do Liquid. O script replica esse comportamento ao transliterar acentos (ex.: `Filosofia da Linguagem` → `/category/filosofia-da-linguagem/`), garantindo que cada link leve ao arquivo correto.
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
2. Ajuste a grafia conforme necessário. Use sempre letras maiúsculas/minúsculas desejadas — o script gerará o slug (`História da Lógica` → `/category/historia-da-logica/`) automaticamente.
3. Execute `ruby scripts/generate_taxonomy_pages.rb`. O script sincroniza os diretórios `category/` e `tag/`, criando novas páginas ou removendo as que ficarem sem posts.
4. Por fim, rode `bundle exec jekyll build` ou `serve` para validar o resultado.

## Script de taxonomias

- `scripts/generate_taxonomy_pages.rb` percorre `_posts/`, coleta categorias e tags e cria/atualiza `index.md` para cada termo.
- O script remove diretórios de termos obsoletos (quando todos os posts deixam de usar aquela tag/categoria), mantendo o repositório enxuto.
- As páginas geradas usam o layout `taxonomy`, que reproduz a grade de arquivos com miniatura, título e data de cada post vinculado.
- Cada arquivo gerado inclui, no front matter, a lista de posts associados (título, permalink, data e miniatura) para que as páginas sigam preenchidas mesmo em builds que não publiquem posts futuros.
- Se preferir automatizar, adicione o comando ao fluxo de CI ou a um hook local (`bin/post-commit`, por exemplo) para evitar que novas taxonomias sejam esquecidas.

## Publicação com GitHub Actions

- Os deploys são publicados automaticamente a partir da branch `main` via workflow [`Build and deploy site`](.github/workflows/deploy.yml).
- O workflow executa `bundle install`, roda `ruby scripts/generate_taxonomy_pages.rb` e, em seguida, `bundle exec jekyll build --trace` usando Ruby 3.2.
- A pasta `_site/` resultante é enviada ao GitHub Pages com `actions/upload-pages-artifact` + `actions/deploy-pages`, garantindo que a versão gerada com Jekyll 4.x seja publicada.
- Não são necessários segredos adicionais: o workflow usa o `GITHUB_TOKEN` padrão para publicar no Pages. Caso precise disparar o deploy manualmente, utilize a ação **Run workflow** no GitHub.

## Estilos, scripts e componentes

- `assets/css/main.css` e `assets/css/custom.css` centralizam o estilo global. Novas regras específicas podem ser adicionadas em arquivos dedicados e incluídas via `extra_css` no front matter.
- Scripts adicionais ficam em `assets/js/`. Para páginas que precisam de JS específico, liste os arquivos em `extra_js`.
- O rodapé e demais blocos recorrentes residem em `_includes/` (`footer.html`, `breadcrumb.html`, `home/intro.html`). Prefira editar esses fragmentos quando houver mudanças estruturais.
