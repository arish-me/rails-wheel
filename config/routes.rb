Rails.application.routes.draw do
  namespace :settings do
    resource :profile, only: [:edit, :update] # Singular resource for profile
    get 'account', to: 'settings#edit_account', as: 'edit_account'
  end

  devise_for :users
  get "dashboard", to: "dashboard#index"
  get "settings", to: "settings#index"
  resources :categories
  resources :role_permissions
  resources :permissions
  resources :user_roles
  resources :roles do
    collection do
      post :bulk_destroy
    end
  end


  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#index"
end
