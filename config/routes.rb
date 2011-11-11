Jukebox2::Application.routes.draw do
  resources :artists do
    get :toggle_favorite, :on => :member
    resources :releases
    resources :tracks
  end

  resources :genres do
    resources :artists
  end

  resources :tracks do
    get :play, :on => :member
  end

  resources :releases do
    get :toggle_favorite, :on => :member
  end

  root :to => "frontpage#index"
end
