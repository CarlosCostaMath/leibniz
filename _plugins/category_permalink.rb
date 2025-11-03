# frozen_string_literal: true

module CategoryPermalink
  module_function

  def assign_category_path(page)
    categories = extract_categories(page)
    slugs = categories.map do |category|
      Jekyll::Utils.slugify(category.to_s, mode: 'latin')
    end.reject(&:empty?)

    page.data['category_path'] = slugs.join('/')
  end

  def extract_categories(page)
    if page.respond_to?(:categories)
      Array(page.categories)
    else
      Array(page.data['categories'])
    end
  end
end

Jekyll::Hooks.register :posts, :pre_render do |post|
  CategoryPermalink.assign_category_path(post)
end
