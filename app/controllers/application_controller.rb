# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Mongoid::Errors::DocumentNotFound, :with => :not_found

  def not_found
    flash[:error] = 'The page you requested does not exist.'
    redirect_to '/'
  end

end
