# encoding: utf-8

# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

module ApplicationHelper

  def formula_link(formula, options = {})
    options = { class: 'formula' }.merge options
    url_options = formula.repository.main? ? formula : [ formula.repository, formula ]
    link_to formula.name, url_for(url_options), options
  end

  def timestamp(time)
    options = {
      class: 'timeago',
      title: l(time, format: :long)
    }
    content_tag :abbr, time.to_s, options
  end

  def title
    title = 'braumeister.org'
    title = "#{@title} – #{title}" unless @title.nil?
    title
  end

end
