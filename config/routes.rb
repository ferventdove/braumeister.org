# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

Braumeister::Application.routes.draw do

  resources :formulae, :only => :index, :path => 'browse' do
    get ':page', :action => :index, :on => :collection
  end

  resources :formulae, :only => :index, :path => 'search' do
    get ':search', :action => :index, :on => :collection
  end

  resources :formulae, :only => :show, :path => 'formula',
            :constraints => { :id => /.*/ }

  root :to => 'home#index'

  match '*url', :to => 'application#not_found'

end
