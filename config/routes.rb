Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  resources :sites, only: [:index, :new, :create, :destroy]

  root "pages#landing"
end
