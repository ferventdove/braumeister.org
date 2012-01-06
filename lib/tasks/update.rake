# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

namespace :braumeister do

  task :update => :environment do
    Rails.logger = Logger.new STDOUT

    HOMEBREW = 'mxcl/homebrew'

    repo = Repository.find_or_create_by :name => HOMEBREW
    repo.refresh
    repo.save!
  end

end
