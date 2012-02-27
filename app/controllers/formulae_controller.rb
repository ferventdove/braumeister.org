# encoding: utf-8

# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'text'

class FormulaeController < ApplicationController

  before_filter :select_repository

  def browse
    if params[:search].nil? || params[:search].empty?
      letter = params[:letter]
      letter = 'a' if letter.nil? || letter.empty?
      @title = "Browse formulae – #{letter.upcase}"
      @formulae = @repository.formulae.letter(letter).where removed: false
    else
      term = params[:search]
      @title = "Search for: #{term}"
      @formulae = @repository.formulae.
        where name: /#{Regexp.escape term}/i, removed: false

      if @formulae.size == 1 && term == @formulae.first.name
        if @repository.main?
          redirect_to formula_path(@formulae.first)
        else
          redirect_to repository_formula_path(@repository.name, @formulae.first)
        end
        return
      end

      @formulae = @formulae.order_by([:name, :asc]).sort_by do |formula|
        Text::Levenshtein.distance(formula.name, term) +
        Text::Levenshtein.distance(formula.name[0..term.size - 1], term)
      end
      @formulae = Kaminari.paginate_array @formulae
    end

    @formulae = @formulae.page(params[:page]).per 50

    fresh_when etag: @repository.sha, public: true
  end

  def feed
    @revisions = @repository.revisions.order_by([:date, :desc]).limit 50

    respond_to do |format|
      format.atom
    end

    fresh_when etag: @repository.sha, public: true
  end

  def sitemap
    respond_to do |format|
      format.xml
    end

    fresh_when etag: @repository.sha, public: true
  end

  def show
    @formula = @repository.formulae.where(name: params[:id]).first
    if @formula.nil?
      formula = @repository.formulae.all_in(aliases: [params[:id]]).first
      unless formula.nil?
        if @repository.main?
          redirect_to formula
        else
          redirect_to repository_formula_path(@repository.name, formula)
        end
        return
      end
      raise Mongoid::Errors::DocumentNotFound.new(Formula, params[:id])
    end
    @title = @formula.name
    @revisions = @formula.revisions.order_by([:date, :desc]).to_a
    @current_revision = @revisions.shift

    fresh_when etag: @current_revision.sha, public: true
  end

  private

  def select_repository
    if request.url.match '/repos/mxcl/homebrew'
      redirect_to request.url.split('/repos/mxcl/homebrew', 2)[1]
      return
    end

    params[:repository_id] ||= 'mxcl/homebrew'
    @repository = Repository.find params[:repository_id].identify
  end

end
