# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authorize_request, only: [:create]

      # POST /api/v1/login
      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          session[:user_id] = user.id
          render json: { id: user.id, email: user.email, name: user.name }, status: :ok
        else
          render json: { errors: ['이메일 또는 비밀번호가 올바르지 않습니다'] }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout
      def destroy
        session.delete(:user_id)
        head :no_content
      end
    end
  end
end
