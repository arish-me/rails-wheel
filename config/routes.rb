Rails.application.routes.draw do
  # Locale switching route
  post "set_locale", to: "application#set_locale", as: :set_locale

  # ActiveStorage direct uploads
  # post '/rails/active_storage/direct_uploads', to: 'active_storage/direct_uploads#create', as: :rails_direct_uploads

  namespace :settings do
    resource :profile, only: [ :show, :destroy ]
    resource :preferences, only: :show
    resource :accounts, only: :show
    get "account", to: "settings#edit_account", as: "edit_account"
  end

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  get "/auth/:provider/callback", to: "sessions#google_auth"
  get "/auth/failure", to: redirect("/")

  get "dashboard", to: "dashboard#index"
  get "settings", to: "settings#index"

  resources :user_roles
  resources :companies
  resource :onboarding, only: :show do
    collection do
      get :profiles_setup
      get :specialization
      get :preferences
      get :goals
      get :trial
    end
  end

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

  resources :notifications, only: [ :index ] do
    member do
      post :mark_as_read
    end
    # collection do
    #   get :users_list
    #   post :send_to_user
    #   get :send, action: :app_sender
    # end
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

  namespace :platform do
    resources :users do
      member do
        post :impersonate
      end
      collection do
        post :bulk_destroy
        post :stop_impersonating
      end
    end
    resources :companies do
      collection do
        post :bulk_destroy
      end
    end
  end

  resources :candidates do
    resources :profiles, module: :candidates
    resources :work_preferences, module: :candidates
    resources :social_links, module: :candidates
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  root "pages#index"
end
