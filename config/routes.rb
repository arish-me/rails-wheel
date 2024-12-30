Rails.application.routes.draw do

  devise_for :users
  get "dashboard", to: "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#index"
end
