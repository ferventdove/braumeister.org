# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Formula

  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :removed, :type => Boolean
  field :name, :type => String
  field :homepage, :type => String
  field :version, :type => String
  key :name

  alias_method :to_param, :name

  embedded_in :repository
  has_and_belongs_to_many :revisions

  def path
    File.join('Library', 'Formula', name) + '.rb'
  end

  def self.letterize(letter)
    letter =~ /\A[A-Za-z]\z/ ? letter.downcase : 'a'
  end

  def self.letter(letter)
    name_starts_with(letter).order_by([:name, :asc])
  end

  def self.name_starts_with(letter)
    where(name: /^#{letter}/)
  end

end
