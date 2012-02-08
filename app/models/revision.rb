# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Revision

  include Mongoid::Document

  field :date, type: Time
  field :subject, type: String
  field :sha, type: String
  key :sha

  belongs_to :repository
  belongs_to :author

  has_and_belongs_to_many :added_formulae, class_name: 'Formula', inverse_of: nil
  has_and_belongs_to_many :updated_formulae, class_name: 'Formula', inverse_of: nil
  has_and_belongs_to_many :removed_formulae, class_name: 'Formula', inverse_of: nil

end
