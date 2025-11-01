# frozen_string_literal: true

require 'jekyll'

module Jekyll
  class TaxonomyPage < PageWithoutAFile
    def initialize(site:, base:, type:, term:, documents: [])
      slug = Utils.slugify(term, mode: 'latin')
      dir = File.join(type, slug)

      super(site, base, dir, 'index.html')

      self.data['layout'] = 'taxonomy'
      self.data['title'] = type == 'tag' ? "##{term}" : term
      self.data['taxonomy_type'] = type
      self.data['taxonomy_term'] = term
      self.data['taxonomy_slug'] = slug
      self.data['permalink'] = "/#{type}/#{slug}/"
      self.data['extra_css'] = ['/assets/css/taxonomy.css']

      count = documents.length
      count_text = count == 1 ? 'publicação' : 'publicações'
      description = if type == 'tag'
                      verb = count == 1 ? 'marcada' : 'marcadas'
                      "#{count} #{count_text} #{verb} com ##{term}."
                    else
                      "#{count} #{count_text} na categoria #{term}."
                    end
      self.data['description'] = description

      sorted = documents.sort_by { |doc| doc.data['date'] || Time.at(0) }.reverse
      self.data['posts'] = sorted

      self.content = ''
    end
  end

  class TaxonomyGenerator < Generator
    safe true
    priority :low

    def generate(site)
      posts = site.posts.docs

      categories = Hash.new { |hash, key| hash[key] = [] }
      tags = Hash.new { |hash, key| hash[key] = [] }

      posts.each do |post|
        Array(post.data['categories']).each do |category|
          next if category.to_s.strip.empty?

          categories[category.to_s] << post
        end

        Array(post.data['tags']).each do |tag|
          next if tag.to_s.strip.empty?

          tags[tag.to_s] << post
        end
      end

      build_taxonomy_pages(site, base: site.source, type: 'category', entries: categories)
      build_taxonomy_pages(site, base: site.source, type: 'tag', entries: tags)
    end

    private

    def build_taxonomy_pages(site, base:, type:, entries: {})
      entries.each do |term, documents|
        next if documents.empty?

        page = TaxonomyPage.new(site: site, base: base, type: type, term: term, documents: documents)
        site.pages << page
      end
    end
  end
end
