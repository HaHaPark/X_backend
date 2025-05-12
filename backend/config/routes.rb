Rails.application.routes.draw do
  # 헬스 체크
  get "up" => "rails/health#show", as: :rails_health_check

  # API 엔드포인트
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
    end
  end

  # 필요시 추가 라우트…
end

