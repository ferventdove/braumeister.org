# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Formula

  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :aliases, type: Array
  field :date, type: Time
  field :removed, type: Boolean
  field :name, type: String
  field :homepage, type: String
  field :version, type: String
  key :repository_id, :name

  alias_method :to_param, :name

  belongs_to :repository
  has_and_belongs_to_many :revisions, inverse_of: nil

  has_and_belongs_to_many :deps, class_name: 'Formula', inverse_of: :revdeps
  has_and_belongs_to_many :revdeps, class_name: 'Formula', inverse_of: :deps

  def path
    File.join('Library', 'Formula', name) + '.rb'
  end

  def self.letter(letter)
    where(name: /^#{letter.downcase}/).order_by([:name, :asc])
  end

end
