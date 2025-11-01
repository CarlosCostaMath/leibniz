#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'pathname'
require 'date'

ROOT = Pathname.new(__dir__).join('..').expand_path
POSTS_DIR = ROOT.join('_posts')
CATEGORY_DIR = ROOT.join('category')
TAG_DIR = ROOT.join('tag')
LAYOUT = 'taxonomy'
TAXONOMY_STYLESHEET = '/assets/css/taxonomy.css'

# Simplified slug generator roughly matching Jekyll's `slugify: 'latin'`
# behaviour (downcase, remove acentos e substituir caracteres não alfanuméricos por hífens)
def slugify(term)
  term
    .unicode_normalize(:nfd)
    .encode('ASCII', replace: '', undef: :replace, invalid: :replace)
    .downcase
    .gsub(/[^a-z0-9]+/, '-')
    .gsub(/^-|-$/, '')
end

# Extract YAML front matter from a post file
# Returns a hash with at least `categories` and `tags` keys
# If parsing fails, an empty hash is returned
def read_front_matter(path)
  content = File.read(path)
  return {} unless content.start_with?('---')

  if content.match(/\A---\s*\n(.*?)\n---\s*/m)
    front_matter = Regexp.last_match(1)
    YAML.safe_load(front_matter, permitted_classes: [Date, Time], aliases: true) || {}
  else
    {}
  end
rescue Psych::Exception => e
  warn "[WARN] Não foi possível ler o front matter de #{path}: #{e.message}"
  {}
end

# Build a mapping from taxonomy term to number of associated posts
def collect_taxonomies
  categories = Hash.new(0)
  tags = Hash.new(0)

  Dir.glob(POSTS_DIR.join('*.md')).each do |post_path|
    data = read_front_matter(post_path)

    Array(data['categories']).each do |category|
      categories[category.to_s] += 1
    end

    Array(data['tags']).each do |tag|
      tags[tag.to_s] += 1
    end
  end

  [categories, tags]
end

# Create or update the Markdown file for a taxonomy term
def ensure_taxonomy_file(base_dir:, type:, term:, slug:, count:)
  dir_path = base_dir.join(slug)
  file_path = dir_path.join('index.md')

  FileUtils.mkdir_p(dir_path)

  title = type == 'tag' ? "##{term}" : term
  permalink = "/#{type}/#{slug}/"
  count_text = count == 1 ? 'publicação' : 'publicações'
  description = if type == 'tag'
                  verb = count == 1 ? 'marcada' : 'marcadas'
                  "#{count} #{count_text} #{verb} com ##{term}."
                else
                  "#{count} #{count_text} na categoria #{term}."
                end

  front_matter = {
    'layout' => LAYOUT,
    'title' => title,
    'taxonomy_type' => type,
    'taxonomy_term' => term,
    'permalink' => permalink,
    'description' => description,
    'extra_css' => [TAXONOMY_STYLESHEET],
  }

  body = "<!-- Página gerada automaticamente. Utilize scripts/generate_taxonomy_pages.rb -->\n"

  front_matter_yaml = front_matter.to_yaml.sub(/\A---\s*\n/, '').strip

  content = <<~MARKDOWN
    ---
    #{front_matter_yaml}
    ---
    #{body}
  MARKDOWN

  unless File.exist?(file_path) && File.read(file_path) == content
    File.write(file_path, content)
    puts "Atualizado: #{file_path.relative_path_from(ROOT)}"
  end
end

def cleanup_taxonomy_files(base_dir:, valid_slugs: [])
  return unless base_dir.directory?

  Dir.children(base_dir).each do |entry|
    next if entry == 'index.html'

    path = base_dir.join(entry)
    next unless path.directory?
    next if valid_slugs.include?(entry)

    FileUtils.rm_rf(path)
    puts "Removido: #{path.relative_path_from(ROOT)}"
  end
end

categories, tags = collect_taxonomies

category_slugs = []
categories.each do |term, count|
  slug = slugify(term)
  category_slugs << slug
  ensure_taxonomy_file(base_dir: CATEGORY_DIR, type: 'category', term: term, slug: slug, count: count)
end

tag_slugs = []
tags.each do |term, count|
  slug = slugify(term)
  tag_slugs << slug
  ensure_taxonomy_file(base_dir: TAG_DIR, type: 'tag', term: term, slug: slug, count: count)
end

cleanup_taxonomy_files(base_dir: CATEGORY_DIR, valid_slugs: category_slugs)
cleanup_taxonomy_files(base_dir: TAG_DIR, valid_slugs: tag_slugs)
