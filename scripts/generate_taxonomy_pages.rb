#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'set'
require 'time'
require 'psych'
require 'date'

ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(ROOT, '_posts')
TAXONOMY_DIRS = {
  tag: File.join(ROOT, 'tag'),
  category: File.join(ROOT, 'category')
}.freeze
LAYOUT_NAME = 'taxonomy'
EXTRA_CSS = ['/assets/css/taxonomy.css'].freeze

class FrontMatter
  FRONT_MATTER_REGEX = /\A---\s*\r?\n(.*?)\r?\n---\s*/m.freeze

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
    posts = Dir.glob(File.join(POSTS_DIR, '**', '*.{md,markdown}'), File::FNM_CASEFOLD)
    errors = []

    groups = {
      tag: Hash.new { |h, k| h[k] = [] },
      category: Hash.new { |h, k| h[k] = [] }
    }

    result = posts.each_with_object(groups) do |path, acc|
      begin
        content = File.read(path)
        data = FrontMatter.load(content)

        title = data['title'].to_s.strip
        date = parse_date(data['date']) || date_from_filename(path)
        permalink = build_permalink(data, path, date)
        next unless permalink

        payload = {
          'title' => title.empty? ? '(Sem título)' : title,
          'date' => date,
          'url' => permalink,
          'hero_image' => preferred_image(data),
          'cover' => data['cover']
        }

        taxonomy_terms(data, 'tags', 'tag').each do |tag|
          acc[:tag][tag] << payload.dup
        end

        taxonomy_terms(data, 'categories', 'category').each do |category|
          acc[:category][category] << payload.dup
        end
      rescue StandardError => e
        errors << { path: path, error: e }
      end
    end

    report_errors(errors)

    result
  end

  def preferred_image(data)
    [data['hero_image'], data['cover'], data['thumbnail'], data['image']].map do |candidate|
      candidate.to_s.strip
    end.find { |candidate| !candidate.empty? }
  end

  def build_permalink(data, path, date)
    explicit = data['permalink']
    if explicit && !explicit.to_s.strip.empty?
      url = explicit.to_s.strip
      return url.start_with?('/') ? url : "/#{url}"
    end

    slug = post_slug(data, path)
    return nil if slug.nil? || slug.empty?

    segments = []
    taxonomy_terms(data, 'categories', 'category').each do |category|
      segments << Slug.latin_slug(category)
    end

    if date
      segments << format('%04d', date.year)
      segments << format('%02d', date.month)
      segments << format('%02d', date.day)
    end

    segments << slug

    "/#{segments.compact.join('/').gsub(%r{//+}, '/')}/"
  end

  def post_slug(data, path)
    explicit_slug = data['slug'].to_s.strip
    return Slug.latin_slug(explicit_slug) unless explicit_slug.empty?

    title = data['title'].to_s.strip
    slug_from_title = Slug.latin_slug(title)
    return slug_from_title unless slug_from_title.nil? || slug_from_title == 'untitled'

    slug_from_filename(path)
  end

  def slug_from_filename(path)
    filename = File.basename(path, File.extname(path))
    if filename =~ /\A\d{4}-\d{2}-\d{2}-(.+)\z/
      Slug.latin_slug(Regexp.last_match(1))
    else
      Slug.latin_slug(filename)
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

  def date_from_filename(path)
    filename = File.basename(path)
    if filename =~ /\A(\d{4})-(\d{2})-(\d{2})-/
      Time.new(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i)
    end
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
    sorted_docs = documents.sort_by { |doc| doc['date'] || Time.at(0) }.reverse
    posts = sorted_docs.map do |doc|
      serialise_post(doc)
    end

    count = posts.length
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
      'extra_css' => EXTRA_CSS,
      'posts' => posts
    }
  end

  def front_matter_to_yaml(data)
    yaml = Psych.dump(data, line_width: -1)
    yaml = yaml.sub(/\A---\s*\n/, "---\n")
    yaml << "---\n"
    yaml
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

  def serialise_post(doc)
    payload = doc.each_with_object({}) do |(key, value), result|
      next if value.nil?

      result[key] = case key
                    when 'date'
                      value.respond_to?(:iso8601) ? value.iso8601 : value
                    else
                      value
                    end
    end

    payload.delete('cover') if payload['cover'] == payload['hero_image']
    payload
  end

  def taxonomy_terms(data, *keys)
    keys.flat_map do |key|
      normalise_terms(data[key])
    end
        .map { |term| term.to_s.strip }
        .reject(&:empty?)
        .uniq
  end

  def normalise_terms(value)
    case value
    when nil
      []
    when Array
      value.flat_map { |item| normalise_terms(item) }
    when String
      value.split(',').map(&:strip)
    else
      Array(value)
    end
  end

  def report_errors(errors)
    return if errors.empty?

    $stderr.puts 'Falha ao processar alguns posts:'
    errors.each do |error|
      $stderr.puts "  - #{error[:path]}: #{error[:error].class}: #{error[:error].message}"
    end

    raise 'não foi possível gerar todas as páginas de taxonomia'
  end
end

Taxonomy.generate
