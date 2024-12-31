Rails.application.routes.draw do
  resources :categories
  resources :role_permissions
  resources :permissions
  resources :user_roles
  resources :roles
  namespace :settings do
    resource :profile, only: [:edit, :update] # Singular resource for profile
    get 'account', to: 'settings#edit_account', as: 'edit_account'
  end

  devise_for :users
  get "dashboard", to: "dashboard#index"
  get "settings", to: "settings#index"

  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#index"
end
