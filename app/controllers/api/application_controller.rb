
class Api::ApplicationController < ActionController::API
  # config.web_console.whitelisted_ips = %w( 0.0.0.0/0 ::/0 )
  def current_user
    return nil if user_logged_params[:auth_token].blank?
    @current_user ||= User.find_by_authentication_token(user_logged_params[:auth_token])
  end

  protected

    def user_logged_params
      params.require(:user).permit(:auth_token)
    end
end