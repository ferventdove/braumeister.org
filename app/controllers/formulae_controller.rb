# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'text'

class FormulaeController < ApplicationController

  def index
    @repository = Repository.where(:name => 'mxcl/homebrew').first

    if params[:search].nil? || params[:search].to_s.empty?
      @formulae = @repository.formulae.page(params[:page]).per(50)
    else
      term = params[:search]
      @formulae = @repository.formulae.where(:name => /#{term}/i)
      @formulae = @formulae.sort_by do |formula|
        Text::Levenshtein.distance(formula.name, term) +
        Text::Levenshtein.distance(formula.name[0..term.size - 1], term)
      end
      @formulae = Kaminari.paginate_array(@formulae).page(params[:page]).per(50)
    end
  end

end
