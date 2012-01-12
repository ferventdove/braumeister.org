# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'text'

class FormulaeController < ApplicationController

  def index
    expires_in 10.minutes, :public => true

    @repository = Repository.where(:name => 'mxcl/homebrew').first

    if params[:search].nil? || params[:search].to_s.empty?
      @formulae = @repository.formulae.order_by([:name, :asc]).
        where(:removed => false).page(params[:page]).per(50)
    else
      term = params[:search]
      @formulae = @repository.formulae.
        where(:name => /#{term}/i, :removed => false)

      if @formulae.size == 1 && term == @formulae.first.name
        redirect_to formula_path(@formulae.first)
      end

      @formulae = @formulae.order_by([:name, :asc]).sort_by do |formula|
        Text::Levenshtein.distance(formula.name, term) +
        Text::Levenshtein.distance(formula.name[0..term.size - 1], term)
      end
      @formulae = Kaminari.paginate_array(@formulae).page(params[:page]).per(50)
    end
  end

  def show
    expires_in 10.minutes, :public => true

    @repository = Repository.where(:name => 'mxcl/homebrew').first
    @formula = @repository.formulae.where(:name => params[:id]).first
    if @formula.nil?
      raise Mongoid::Errors::DocumentNotFound.new(Formula, params[:id])
    end
    @revisions = @formula.revisions.order_by([:date, :desc]).to_a
    @current_revision = @revisions.shift
  end

end
