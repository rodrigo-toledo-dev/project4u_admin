
class Api::ApplicationController < ActionController::API
  before_action :set_client

  def current_user
    return nil if user_params[:auth_token].blank?
    @current_user ||= User.find_by_authentication_token(user_params[:auth_token])
  end

  protected
    def user_params
      @user_params = params.require(:user)
      if @user_params.is_a?(String)
        require 'json'
        params[:user] = JSON.parse(@user_params, {symbolize_names: true})
      end
      params.require(:user).permit(:auth_token, :first_name, :last_name, :email, :client_name, :password, :password_confirmation, :uuid, :gcm_reg_id, :version, :loading)
    end

    def set_client
      @client ||= Client.find_by_name(user_params[:client_name])
      return head 404 if @client.nil?
      @client
    end
end