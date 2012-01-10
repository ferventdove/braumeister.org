# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Revision

  include Mongoid::Document

  field :date, :type => Time
  field :subject, :type => String
  field :sha, :type => String
  key :sha

  belongs_to :repository
  belongs_to :author

end
