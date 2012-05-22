Sokojax::Application.routes.draw do
  mount Jax::Engine => "/jax" unless Rails.env == "production"
  
  # Resources
  resources :packs do
    resources :levels
  end
  
  # Root
  root :to => "packs#show", :id => 'Original & Extra'
  
  # OmniAuth (facebook)
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'
  get '/login', :to => 'sessions#new'
  get '/logout', :to => 'sessions#destroy' 
end
