Braumeister::Application.routes.draw do

  match '/search/:search' => 'formula#index'

  root :to => 'formula#index'

end
