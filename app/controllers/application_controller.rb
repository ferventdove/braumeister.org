# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Mongoid::Errors::DocumentNotFound, :with => :not_found

  def not_found
    unless respond_to? :index
      render :nothing => true, :status => :not_found
      return
    end

    flash.now[:error] = 'The page you requested does not exist.'

    index

    expires_in 5.minutes
    render :index, :status => :not_found
  end

end
