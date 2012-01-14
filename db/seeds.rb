# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

Repository.find_or_create_by name: 'mxcl/homebrew'

Repository.all.each do |repo|
  repo.refresh
  repo.save!
end
