# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

Braumeister::Application.routes.draw do

  resources :formulae, only: :index, path: 'browse' do
    get ':letter(/:page)', action: :index, on: :collection,
        as: :letter,
        constraints: { letter: /[A-Za-z]/, page: /\d+/ }
  end

  resources :formulae, only: :index, path: 'search' do
    get '' => redirect('/browse/a'), on: :collection
    get ':search(/:page)', action: :index, on: :collection,
        as: :search,
        constraints: { page: /\d+/ }
  end

  resources :formula, controller: :formulae, only: :show,
            constraints: { id: /.*/ }

  match '/feed' => 'formulae#feed', as: :feed

  root to: 'application#home'

  match '*url', to: 'application#not_found'

end
