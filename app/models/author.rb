# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Author

  include Mongoid::Document
  
  field :email, :type => String
  field :name, :type => String
  key :email
  
  belongs_to :repository
  has_many :revisions
  
end