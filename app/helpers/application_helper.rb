# encoding: utf-8

# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

module ApplicationHelper

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
