
class Api::ApplicationController < ActionController::API
  # config.web_console.whitelisted_ips = %w( 0.0.0.0/0 ::/0 )
  def current_user
    require 'json'
    new_params = JSON.parse(params.keys.first)
    new_params = new_params.symbolize_keys[:user].symbolize_keys
    return nil if new_params[:auth_token].blank?
    @current_user ||= User.find_by_authentication_token(new_params[:auth_token])
  end
end