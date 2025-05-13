module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authorize_request, only: [:create]

      # GET /api/v1/users
      def index
        result = UserManagementService.list
        render json: result.users, status: :ok
      end

      # POST /api/v1/users
      def create
        result = UserManagementService.register(user_params)
        if result.success?
          render json: {
            id:    result.user.id,
            email: result.user.email,
            name:  result.user.name
          }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name)
      end
    end
  end
end
