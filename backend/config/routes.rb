Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post   'login',  to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      resources :users, only: [:create, :index]
      
      resources :workspaces, only: [:index, :show, :create, :update, :destroy] do
        post 'join', on: :member
      end   

      resources :tasks, only: [:show, :update, :destroy]
    end  # namespace :v1
  end    # namespace :api
end    # routes.draw
