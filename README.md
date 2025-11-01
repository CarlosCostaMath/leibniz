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
category/, tag/    → Páginas individuais de categorias e tags (geradas automaticamente pelo plugin `_plugins/taxonomy_generator.rb`)
*.html, *.md na raiz → Páginas fixas (Início, Sobre, Contato, Arquivos, Tags, Categorias)
```

## Taxonomias e navegação

- O menu principal é definido em `_data/navigation.yml`.
- `categories.md`, `tags.md` e `archives.md` geram as páginas de índice. As páginas individuais de cada tag e categoria são criadas dinamicamente pelo plugin `_plugins/taxonomy_generator.rb`, que replica a estrutura `tag/<slug>/index.html` e `category/<slug>/index.html` durante o build.
  - Os links exibidos nos posts (`_layouts/post.html`) usam o filtro `slugify: 'latin'` do Liquid, correspondente ao algoritmo utilizado pelo plugin para montar os diretórios, garantindo que cada tag/categoria aponta para o arquivo correto mesmo com acentuação ou cedilha.
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
2. Ajuste a grafia conforme necessário. O Jekyll criará automaticamente slugs (no modo `latin`) a partir dos nomes (`História da Lógica` → `/category/historia-da-logica/`).
3. Salve o arquivo e execute `bundle exec jekyll serve` (ou o comando de build usado no projeto). O plugin de taxonomias localizará as categorias e tags declaradas, criará as páginas individuais necessárias e atualizará os links durante o build.

## Geração automática de taxonomias

- `_plugins/taxonomy_generator.rb` percorre todos os documentos em `_posts/`, coleta as categorias e tags preenchidas e instancia páginas virtuais para cada termo.
- As páginas recebem o layout `taxonomy`, a folha de estilo `assets/css/taxonomy.css` e a lista de posts correspondente diretamente do gerador, garantindo que nenhuma página fique vazia.
- A remoção de uma categoria ou tag de todos os posts impede que a página correspondente seja criada no build seguinte, evitando páginas órfãs sem necessidade de scripts auxiliares.

## Estilos, scripts e componentes

- `assets/css/main.css` e `assets/css/custom.css` centralizam o estilo global. Novas regras específicas podem ser adicionadas em arquivos dedicados e incluídas via `extra_css` no front matter.
- Scripts adicionais ficam em `assets/js/`. Para páginas que precisam de JS específico, liste os arquivos em `extra_js`.
- O rodapé e demais blocos recorrentes residem em `_includes/` (`footer.html`, `breadcrumb.html`, `home/intro.html`). Prefira editar esses fragmentos quando houver mudanças estruturais.
