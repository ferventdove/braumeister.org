# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Formula

  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :aliases, type: Array
  field :date, type: Time
  field :keg_only, type: Boolean, default: false
  field :removed, type: Boolean, default: false
  field :name, type: String
  field :homepage, type: String
  field :path, type: String
  field :version, type: String
  key :repository_id, :name

  alias_method :to_param, :name

  belongs_to :repository
  has_and_belongs_to_many :revisions, inverse_of: nil

  has_and_belongs_to_many :deps, class_name: 'Formula', inverse_of: :revdeps
  has_and_belongs_to_many :revdeps, class_name: 'Formula', inverse_of: :deps

  scope :letter, ->(letter) { where(name: /^#{letter.downcase}/) }

  def path
    path = repository.full? ? File.join('Library', 'Formula') : self[:path]
    (path.nil? ? name : File.join(path, name)) + '.rb'
  end

  def raw_url
    "https://raw.github.com/#{repository.name}/HEAD/#{path}"
  end

end
