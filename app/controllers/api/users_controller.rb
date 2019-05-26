class Api::UsersController < Api::ApplicationController
  def create
    client = Client.find_by_name(sign_up_params[:client_name])
    return head 404 if client.nil?

    email, password, uuid = sign_up_params[:email], sign_up_params[:password], sign_up_params[:uuid]
    user = User.find_by_email(email)
    return head 401 if user
    
    user = client.users.build(
      first_name: sign_up_params[:first_name],
      last_name: sign_up_params[:last_name],
      email: sign_up_params[:email],
      password: sign_up_params[:password],
      password_confirmation: sign_up_params[:password_confirmation],
    )
    unless user.save
      logger.info user.errors.full_messages
      return head 422
    end
    user.ensure_authentication_token!
    Device.register(sign_up_params, user)

    render json: { auth_token: user.authentication_token }
  end

  def sign_in
    email, password = sign_up_params[:email], sign_up_params[:password]
    user = User.find_by_email(email)
    return head 404 if user.nil?

    return head 400 unless user.valid_password?(password)

    user.ensure_authentication_token!
    Device.register(sign_up_params, user)

    render json: { auth_token: user.authentication_token }
  end
  

  protected
    def sign_up_params
      require 'json'
      new_params = JSON.parse(params.keys.first)
      new_params.symbolize_keys[:user].symbolize_keys
    end
end