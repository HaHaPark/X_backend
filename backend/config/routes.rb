Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # login
      post   'login',  to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'

      # user
      resources :users, only: [:create, :index]
      
      # workspace

      # public workspace list
      get 'workspaces/public', to: 'workspaces#public_index'

      resources :workspaces, only: [:index, :show, :create, :update, :destroy] do
        post   'join', on: :member
      
        resources :tasks, only: [:index, :create]
      end

      # task (show/update/destroy)
      resources :tasks, only: [:show, :update, :destroy]
    end
  end
end
