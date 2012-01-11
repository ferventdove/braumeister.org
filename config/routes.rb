# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

Braumeister::Application.routes.draw do

  resources :formulae, :only => :index, :path => '' do
    get 'page/:page', :action => :index, :on => :collection
    get 'search/:search', :action => :index, :on => :collection
  end

  resources :formulae, :only => :show, :path => 'formula'

  match '*url', :to => 'application#not_found'

end
