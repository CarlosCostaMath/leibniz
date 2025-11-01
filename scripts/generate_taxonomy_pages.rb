#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'set'
require 'time'

ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(ROOT, '_posts')
TAXONOMY_DIRS = {
  tag: File.join(ROOT, 'tag'),
  category: File.join(ROOT, 'category')
}.freeze
LAYOUT_NAME = 'taxonomy'
EXTRA_CSS = ['/assets/css/taxonomy.css'].freeze

class FrontMatter
  FRONT_MATTER_REGEX = /\A---\s*\n(.*?)\n---\s*/m.freeze

  def self.load(content)
    match = content.match(FRONT_MATTER_REGEX)
    return {} unless match

    YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
  end
end

module Slug
  module_function

  TRANSLITERATIONS = {
    'á' => 'a', 'à' => 'a', 'ã' => 'a', 'â' => 'a', 'ä' => 'a',
    'Á' => 'a', 'À' => 'a', 'Ã' => 'a', 'Â' => 'a', 'Ä' => 'a',
    'é' => 'e', 'è' => 'e', 'ê' => 'e', 'ë' => 'e',
    'É' => 'e', 'È' => 'e', 'Ê' => 'e', 'Ë' => 'e',
    'í' => 'i', 'ì' => 'i', 'î' => 'i', 'ï' => 'i',
    'Í' => 'i', 'Ì' => 'i', 'Î' => 'i', 'Ï' => 'i',
    'ó' => 'o', 'ò' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o',
    'Ó' => 'o', 'Ò' => 'o', 'Ô' => 'o', 'Õ' => 'o', 'Ö' => 'o',
    'ú' => 'u', 'ù' => 'u', 'û' => 'u', 'ü' => 'u',
    'Ú' => 'u', 'Ù' => 'u', 'Û' => 'u', 'Ü' => 'u',
    'ñ' => 'n', 'Ñ' => 'n',
    'ç' => 'c', 'Ç' => 'c'
  }.freeze

  def latin_slug(term)
    transliterated = term.to_s.each_char.map { |char| TRANSLITERATIONS.fetch(char, char) }.join
    slug = transliterated.downcase.gsub(/[^a-z0-9\s-]/, ' ')
    slug = slug.strip.gsub(/\s+/, '-').gsub(/-+/, '-')
    slug.empty? ? 'untitled' : slug
  end
end

module Taxonomy
  module_function

  def collect_posts
    posts = Dir.glob(File.join(POSTS_DIR, '*.{md,markdown}'))
    posts.each_with_object({ tag: Hash.new { |h, k| h[k] = [] }, category: Hash.new { |h, k| h[k] = [] } }) do |path, acc|
      content = File.read(path)
      data = FrontMatter.load(content)

      title = data['title'].to_s.strip
      date = parse_date(data['date'])

      Array(data['tags']).each do |tag|
        next if tag.to_s.strip.empty?

        acc[:tag][tag.to_s] << { 'title' => title, 'date' => date }
      end

      Array(data['categories']).each do |category|
        next if category.to_s.strip.empty?

        acc[:category][category.to_s] << { 'title' => title, 'date' => date }
      end
    end
  end

  def parse_date(value)
    case value
    when Time then value
    when Date then value.to_time
    when String then Time.parse(value)
    else
      nil
    end
  rescue ArgumentError
    nil
  end

  def ensure_directories
    TAXONOMY_DIRS.each_value do |dir|
      FileUtils.mkdir_p(dir)
    end
  end

  def generate
    ensure_directories
    taxonomies = collect_posts

    taxonomies.each do |type, entries|
      write_taxonomy(type, entries)
    end
  end

  def write_taxonomy(type, entries)
    base_dir = TAXONOMY_DIRS.fetch(type)
    keep_paths = Set.new

    entries.sort_by { |term, _| Slug.latin_slug(term) }.each do |term, documents|
      next if documents.empty?

      slug = Slug.latin_slug(term)
      dir = File.join(base_dir, slug)
      FileUtils.mkdir_p(dir)

      page_path = File.join(dir, 'index.md')
      keep_paths << page_path

      front_matter = build_front_matter(type, term, slug, documents)
      content = front_matter_to_yaml(front_matter)

      if !File.exist?(page_path) || File.read(page_path) != content
        File.write(page_path, content)
        puts "[#{type}] wrote #{page_path.sub(ROOT + '/', '')}"
      end
    end

    remove_stale_entries(base_dir, keep_paths)
  end

  def build_front_matter(type, term, slug, documents)
    count = documents.length
    count_text = count == 1 ? 'publicação' : 'publicações'

    description = if type == :tag
                    verb = count == 1 ? 'marcada' : 'marcadas'
                    "#{count} #{count_text} #{verb} com ##{term}."
                  else
                    "#{count} #{count_text} na categoria #{term}."
                  end

    {
      'layout' => LAYOUT_NAME,
      'title' => type == :tag ? "##{term}" : term,
      'taxonomy_type' => type.to_s,
      'taxonomy_term' => term,
      'taxonomy_slug' => slug,
      'permalink' => "/#{type}/#{slug}/",
      'description' => description,
      'extra_css' => EXTRA_CSS
    }
  end

  def front_matter_to_yaml(data)
    lines = ["---\n"]
    data.each do |key, value|
      case value
      when Array
        lines << "#{key}:\n"
        value.each { |item| lines << "  - #{item}\n" }
      else
        lines << "#{key}: #{value}\n"
      end
    end
    lines << "---\n"
    lines.join
  end

  def remove_stale_entries(base_dir, keep_paths)
    Dir.glob(File.join(base_dir, '*')).each do |entry|
      next if File.basename(entry) == 'index.html'

      if File.directory?(entry)
        index_path = File.join(entry, 'index.md')
        next if keep_paths.include?(index_path)

        FileUtils.rm_rf(entry)
        puts "removed stale #{entry.sub(ROOT + '/', '')}"
      end
    end
  end
end

Taxonomy.generate
