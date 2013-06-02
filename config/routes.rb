Sokojax::Application.routes.draw do
  mount Jax::Engine => "/jax" unless Rails.env == "production"

  # Resources  =>  /.*/ to get the '.' in the names
  resources :packs, :pack_id => /.*/ do
    resources :levels, :id => /.*/
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
      get :show_twitter_page
      get :show_invite_friends
      get :show_random_level
      get :show_donation

      post :show_next_level
    end
  end

  resources :scores

  resources :users do
    member do
      get  :popular_friends
      get  :is_like_facebook_page       # question
      get  :custom_invitation           # JSON with data for custom user invitation
      post :update_send_invitations_at  # user just invited some friends
      get  :unsubscribe_from_mailing    # remove user from mailing list (remove from madmimi)
    end
  end

  get '/rankings',        :to => 'users#index', :type => 'global',  :as => :rankings
  get '/friends_ranking', :to => 'users#index', :type => 'friends', :as => :friends_ranking

  # Root
  root :to => "packs#show", :id => 'Dimitri & Yorick' # or 'Novoban'

  # OmniAuth (facebook)
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure',            :to => 'sessions#failure'
  get   '/login',                   :to => 'sessions#new'
  get   '/logout',                  :to => 'sessions#destroy'

  get   '/banner',                  :to => 'pages#banner'
  get   '/privacy_policy',          :to => 'pages#privacy_policy'
  get   '/terms_of_service',        :to => 'pages#terms_of_service'
  get   '/stats',                   :to => 'pages#stats'
end
