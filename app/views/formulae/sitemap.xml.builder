# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

xml.instruct!
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url do
    xml.loc root_url
    xml.lastmod @repository.updated_at.iso8601
    xml.changefreq 'hourly'
    xml.priority 1.0
  end

  ('a'..'z').each do |letter|
    xml.url do
      xml.loc letter_formulae_url(letter: letter)
      xml.lastmod @repository.updated_at.iso8601
      xml.changefreq 'hourly'
      xml.priority 0.8
    end
  end

  xml.url do
    xml.loc feed_url(format: :atom)
    xml.lastmod @repository.updated_at.iso8601
    xml.changefreq 'hourly'
    xml.priority 0.6
  end

  @repository.formulae.each do |formula|
    xml.url do
      xml.loc polymorphic_url(formula, only_path: false)
      xml.lastmod formula.updated_at.iso8601
      xml.changefreq 'hourly'
    end
  end
end
