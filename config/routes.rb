Jukebox2::Application.routes.draw do
  resources :artists do
    get :toggle_favorite, :on => :member
    get :update_metadata, :on => :member
    resources :tracks
  end

  resources :tracks do
    get :play, :on => :member
    get :toggle_favorite, :on => :member
  end

  resources :releases do
    get :toggle_favorite, :on => :member
    resources :tracks
  end

  resources :sources do
    get :reindex, :on => :collection
  end

  resources :playlists do
    resources :tracks
  end

  root :to => "frontpage#index"
end
