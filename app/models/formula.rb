# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Formula

  include Mongoid::Document

  field :removed, :type => Boolean
  field :name, :type => String
  field :homepage, :type => String
  field :version, :type => String
  key :name

  embedded_in :repository

  def path
    File.join(repository.path, 'Library', 'Formula', name) + '.rb'
  end

end
