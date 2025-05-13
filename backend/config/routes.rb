Rails.application.routes.draw do
  # check
  get "up" => "rails/health#show", as: :rails_health_check

  # API endpoint
  namespace :api do
    namespace :v1 do
      post   'login',  to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      resources :users, only: [:create, :index]
      resources :workspaces, only: [:index, :show, :create, :update, :destroy]
    end
  end

end

