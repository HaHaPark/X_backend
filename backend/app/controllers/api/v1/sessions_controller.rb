module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authorize_request, only: [:create]

      # POST /api/v1/login
      def create
        result = AuthenticationService.authenticate(params[:email], params[:password])
        if result.success?
          session[:user_id] = result.user.id
          render json: {
            id:    result.user.id,
            email: result.user.email,
            name:  result.user.name
          }, status: :ok
        else
          render json: { errors: result.errors }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout
      def destroy
        reset_session
        head :no_content
      end
    end
  end
end
