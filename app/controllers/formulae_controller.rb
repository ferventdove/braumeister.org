# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'text'

class FormulaeController < ApplicationController

  def index
    @repository = Repository.where(:name => 'mxcl/homebrew').first
    @letter     = @repository.formulae.letterize(params[:letter])

    if params[:search].nil? || params[:search].to_s.empty?
      @formulae = @repository.formulae.letter(@letter).
        where :removed => false
    else
      term = params[:search]
      @formulae = @repository.formulae.
        where :name => /#{term}/i, :removed => false

      if @formulae.size == 1 && term == @formulae.first.name
        redirect_to formula_path(@formulae.first)
      end

      @formulae = @formulae.order_by([:name, :asc]).sort_by do |formula|
        Text::Levenshtein.distance(formula.name, term) +
        Text::Levenshtein.distance(formula.name[0..term.size - 1], term)
      end
      @formulae = Kaminari.paginate_array @formulae
    end

    @formulae = @formulae.page(params[:page]).per 50

    fresh_when :etag => @repository.sha, :public => true
  end

  def show
    @repository = Repository.where(:name => 'mxcl/homebrew').first
    @formula = @repository.formulae.where(:name => params[:id]).first
    if @formula.nil?
      raise Mongoid::Errors::DocumentNotFound.new(Formula, params[:id])
    end
    @revisions = @formula.revisions.order_by([:date, :desc]).to_a
    @current_revision = @revisions.shift

    fresh_when :etag => @current_revision.sha, :public => true
  end

end
