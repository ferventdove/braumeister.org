# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class FormulaController < ApplicationController

  def index
    @repository = Repository.where(:name => 'mxcl/homebrew').first
    @formulae = @repository.formulae.page(params[:page]).per(50)
  end

end
