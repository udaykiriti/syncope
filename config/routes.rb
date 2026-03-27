Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "dashboard" => "pages#dashboard", as: :dashboard

  root "pages#landing"
end
