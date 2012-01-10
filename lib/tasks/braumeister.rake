# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

namespace :braumeister do

  Rails.logger = Logger.new STDOUT

  HOMEBREW = 'mxcl/homebrew'

  desc 'Regenerates the history of all formulae in the repository'
  task :regenerate_history => :environment do
    repo = Repository.find_or_create_by :name => HOMEBREW
    repo.generate_history!
  end

  desc 'Pulls the latest changes from or clones the repository'
  task :update => :environment do
    repo = Repository.find_or_create_by :name => HOMEBREW
    repo.refresh
    repo.save!
  end

end
