# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../scripts/generate_taxonomy_pages'

class SlugTest < Minitest::Test
  TERMS = {
    'Søren Kierkegaard' => 'soren-kierkegaard',
    'Æon' => 'aeon',
    'Straße' => 'strasse',
    'Olá Mundo!' => 'ola-mundo',
    'Český Krumlov' => 'cesky-krumlov',
    '' => 'untitled'
  }.freeze

  def test_latin_slug_matches_expected_values
    skip 'Jekyll gem not available' unless defined?(::JEKYLL_AVAILABLE) && ::JEKYLL_AVAILABLE

    TERMS.each do |term, expected|
      assert_equal(expected, Slug.latin_slug(term), "slug for '#{term}' did not match")
    end
  end
end
