# encoding: utf-8

# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

atom_feed id: "tag:braumeister.org:#{@repository.name}", schema_date: 2012 do |feed|
  feed.title "braumeister.org – Recent changes in #{@repository.name}"
  feed.updated @repository.updated_at

  @formulae.each do |formula|
    revisions = formula.revisions.order_by [:date, :asc]
    entry_options = {
      id: "tag:braumeister.org:#{@repository.name}/#{formula.name}",
      published: revisions.first.date,
      updated: formula.date
    }
  
    feed.entry formula, entry_options, do |entry|
      title = "#{formula.name} has been "
      if formula.removed?
        title << 'removed'
      elsif formula.revisions.size == 1
        title << 'added'
      else
        title << 'updated'
      end
      entry.title title
      entry.summary revisions.last.subject
      
      entry.author do |author|
        author.name revisions.last.author.name
      end
    end
  end
end
