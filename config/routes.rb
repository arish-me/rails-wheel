Rails.application.routes.draw do

  resources :technologies do
    collection do
      post :bulk_destroy
    end
    resources :topics do

    end
  end
  resources :courses do
    collection do
      post :bulk_destroy
    end
    resources :topics do
      resources :chapters
    end
  end
  namespace :settings do
    resource :profile, only: [:edit, :update] # Singular resource for profile
    get 'account', to: 'settings#edit_account', as: 'edit_account'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  get '/auth/:provider/callback', to: 'sessions#google_auth'
  get '/auth/failure', to: redirect('/')

  get "dashboard", to: "dashboard#index"
  get "settings", to: "settings#index"

  resources :user_roles

  resources :role_permissions do
    collection do
      post :bulk_destroy
    end
  end

  resources :permissions do
    collection do
      post :bulk_destroy
    end
  end

  resources :roles do
    collection do
      post :bulk_destroy
    end
  end

  resources :categories do
    collection do
      post :bulk_destroy
    end
  end

  namespace :admin do
    resources :users do
      member do
        post :impersonate
      end
      collection do
        post :bulk_destroy
        post :stop_impersonating
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#index"
end
