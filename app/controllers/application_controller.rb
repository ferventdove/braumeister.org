# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

  def home
    @repository = Repository.where(name: 'mxcl/homebrew').first
    formulae = @repository.formulae.order_by([:updated_at, :desc])

    @added, @updated, @removed = [], [], []
    formulae.each do |formula|
      if @added.size < 5 && formula.revision_ids.size == 1
        @added << formula
      elsif @updated.size < 5 && !formula.removed? &&
            formula.revision_ids.size > 1
        @updated << formula
      elsif @removed.size < 5 && formula.removed?
        @removed << formula
      end

      break if @added.size == 5 && @updated.size == 5 && @removed.size == 5
    end

    fresh_when etag: @repository.sha, public: true
  end

  def not_found
    flash.now[:error] = 'The page you requested does not exist.'
    home

    respond_to do |format|
      format.html { render :home, status: :not_found }
    end

    headers.delete 'ETag'
    expires_in 5.minutes
  end

end
