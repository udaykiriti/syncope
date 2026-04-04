Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  resources :sites do
    member do
      post :ping
    end
    collection do
      post :ping_all
    end
  end

  # Public status badge API
  get "api/status/:id", to: "sites#status_badge", as: :status_badge

  root "pages#landing"
end
