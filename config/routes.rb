Rails.application.routes.draw do
  resources :themes

  resources :sites do
    resources :pages
  end

  namespace :settings do
    resource :profile, only: [:edit, :update] # Singular resource for profile
    get 'account', to: 'settings#edit_account', as: 'edit_account'
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',        # Custom sessions controller
  }
  get "dashboard", to: "dashboard#index"
  get "settings", to: "settings#index"

  resources :user_roles

  constraints ->(req) { Site.exists?(subdomain: req.subdomain) } do
    root to: "public_sites#show", as: :public_site
    get '/:slug', to: 'public_sites#page', as: :dynamic_page
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

  resources :accounts do
    post :impersonate, to: 'impersonations#create'
    delete :stop_impersonating, to: 'impersonations#destroy'
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
  root "home#index"
end
