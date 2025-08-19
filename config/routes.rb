Rails.application.routes.draw do
  get "job_board_providers/index"
  get "job_board_providers/show"
  get "job_board_integrations/index"
  get "job_board_integrations/show"
  get "job_board_integrations/new"
  get "job_board_integrations/create"
  get "job_board_integrations/edit"
  get "job_board_integrations/update"
  get "job_board_integrations/destroy"
  get "job_board_integrations/test_connection"
  get "job_board_integrations/sync_job"
  # Locale switching route
  post "set_locale", to: "application#set_locale", as: :set_locale

  # ActiveStorage direct uploads
  # post '/rails/active_storage/direct_uploads', to: 'active_storage/direct_uploads#create', as: :rails_direct_uploads

  # Public pages
  get "pricing", to: "pages#pricing", as: :pricing
  get "contact", to: "pages#contact", as: :contact
  get "features", to: "pages#features", as: :features
  get "about", to: "pages#about", as: :about
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service
  get "talent-search", to: "pages#talent_search", as: :talent_search

  namespace :settings do
    resource :profile, only: [ :show, :destroy ]
    resource :preferences, only: :show
    resource :accounts, only: :show
    resource :company, only: :show
    get "account", to: "settings#edit_account", as: "edit_account"
  end

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations",
    sessions: "users/sessions",
    invitations: "users/invitations"
  }
  get "/auth/:provider/callback", to: "sessions#google_auth"
  get "/auth/failure", to: redirect("/")

  get "dashboard", to: "dashboard#index"
  get "settings", to: "settings#index"

  resources :user_roles
  resources :companies
  resource :onboarding, only: :show do
    collection do
      get :profile_setup
      post :profile_setup
      get :specialization
      post :specialization

      get :candidate_setup
      post :candidate_setup

      get :online_presence
      post :online_presence

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

  resources :jobs do
    member do
      patch :publish
      patch :close
    end

    resources :job_applications, only: [ :index, :show, :new, :create, :edit, :update ] do
      member do
        patch :withdraw
        patch :re_apply
        patch :update_status
        get :success
      end
    end
  end

  # Job Board Integrations
  resources :job_board_integrations do
    member do
      post :test_connection
      post :sync_job
    end
  end

  resources :job_board_providers, only: [ :index, :show ]

  resources :notifications, only: [ :index ] do
    member do
      post :mark_as_read
    end
    # collection do
    #   post :mark_all_as_read
    # end
  end

  # Public job board
  namespace :public do
    resources :jobs, only: [ :index, :show ] do
      collection do
        get :search
      end
    end
  end

  # Platform admin routes
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

  # resources :candidates do
  #   resources :profiles, module: :candidates
  #   resources :work_preferences, module: :candidates
  #   resources :social_links, module: :candidates
  # end

  resources :candidates
  resources :experiences
  get "/locations/city_suggestions", to: "locations#city_suggestions"

  # Company candidates management
  resources :company_candidates, only: [ :index, :show ] do
    collection do
      post :bulk_actions
    end
    member do
      patch :update_status
      patch :add_note
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  root "pages#index"
end
