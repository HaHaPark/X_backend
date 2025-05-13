module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authorize_request, only: [:create]

      # GET /api/v1/users
      def index
        users = User.select(:id, :email, :name)
        render json: users, status: :ok
      end

      # POST /api/v1/users
      def create
        user = User.new(user_params)
        if user.save
          render json: {
            id:    user.id,
            email: user.email,
            name:  user.name
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name)
      end
    end
  end
end
