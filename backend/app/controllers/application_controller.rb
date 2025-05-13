class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authorize_request

  private

  def authorize_request
    @current_user = User.find_by(id: session[:user_id])
    unless @current_user
      render json: { errors: ['ログインが必要です。'] }, status: :unauthorized
    end
  end
end

