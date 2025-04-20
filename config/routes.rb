Rails.application.routes.draw do
  # Locale switching route
  post 'set_locale', to: 'application#set_locale', as: :set_locale

  # ActiveStorage direct uploads
  # post '/rails/active_storage/direct_uploads', to: 'active_storage/direct_uploads#create', as: :rails_direct_uploads

  namespace :settings do
    resource :profile, only: [ :edit, :update ] do # Singular resource for profile
      patch :update_avatar
      delete :delete_avatar
      patch :update_theme
    end
    get "account", to: "settings#edit_account", as: "edit_account"
  end

  devise_for :users, controllers: { 
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }
  get "/auth/:provider/callback", to: "sessions#google_auth"
  get "/auth/failure", to: redirect("/")

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
