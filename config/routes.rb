Sokojax::Application.routes.draw do
  mount Jax::Engine => "/jax" unless Rails.env == "production"

  # Resources
  resources :packs do
    resources :levels
  end

  resources :levels do
    collection do
      get :random
    end
  end

  resources :workflows do
    collection do
      get :show_welcome
      get :show_rules
      get :show_controls

      get :show_facebook_page
      get :show_invite_friends
      get :show_random_level

      post :show_next_level
    end
  end

  resources :scores

  resources :users do
    member do
      get :popular_friends
      get :is_like_facebook_page # question
      post :update_send_invitations_at # user just invited some friends
    end
  end

  # Root
  root :to => "packs#show", :id => 'Novoban'

  # OmniAuth (facebook)
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure',            :to => 'sessions#failure'
  get   '/login',                   :to => 'sessions#new'
  get   '/logout',                  :to => 'sessions#destroy'

  get   '/banner',                  :to => 'application#banner'

  get   '/privacy_policy',          :to => 'application#privacy_policy'
  get   '/terms_of_service',        :to => 'application#terms_of_service'

  get   '/stats',                   :to => 'application#stats'
end
