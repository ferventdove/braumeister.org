# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

Braumeister::Application.routes.draw do

  resources :repositories, path: 'repos', only: [],
            constraints: { repository_id: /[0-9A-Za-z_-]+?\/[0-9A-Za-z_-]+/ } do
    resources :formulae, only: :browse, path: 'browse' do
      get ':letter(/:page)', action: :browse, on: :collection,
          as: :letter,
          constraints: { letter: /[A-Za-z]/, page: /\d+/ }
    end

    resources :formulae, only: :browse, path: 'search' do
      get '', action: :browse, on: :collection, as: :search_root
      get ':search(/:page)', action: :browse, on: :collection,
          as: :search,
          constraints: { page: /\d+/, search: /[^\/]+/ }
    end

    resources :formula, controller: :formulae, only: :show,
              constraints: { id: /.*/ }

    match '/' => 'formulae#index'

    match '/feed' => 'formulae#feed', as: :feed
  end

  resources :formulae, only: :browse, path: 'browse' do
    get ':letter(/:page)', action: :browse, on: :collection,
        as: :letter,
        constraints: { letter: /[A-Za-z]/, page: /\d+/ }
  end

  resources :formulae, only: :browse, path: 'search' do
    get '', action: :browse, on: :collection, as: :search_root
    get ':search(/:page)', action: :browse, on: :collection,
        as: :search,
        constraints: { page: /\d+/, search: /[^\/]+/ }
  end

  resources :formula, controller: :formulae, only: :show,
            constraints: { id: /.*/ }

  match '/feed' => 'formulae#feed', as: :feed

  match '/sitemap' => 'formulae#sitemap', as: :sitemap

  root to: 'formulae#index'

  match '*url', to: 'application#not_found'

end
