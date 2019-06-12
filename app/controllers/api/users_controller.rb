class Api::UsersController < Api::ApplicationController
  def create
    user = User.find_by_email(user_params[:email])
    logger.info user.inspect
    return head 401 if user
    
    user = @client.users.build(
      first_name: user_params[:first_name],
      last_name: user_params[:last_name],
      email: user_params[:email],
      password: user_params[:password],
      password_confirmation: user_params[:password_confirmation],
    )
    unless user.save
      logger.info user.errors.full_messages
      return head 422
    end
    user.ensure_authentication_token!
    Device.register(user_params, user)

    render json: { auth_token: user.authentication_token, client_name: @client.name, email: user.email }
  end

  def sign_in
    email, password = user_params[:email], user_params[:password]
    user = User.find_by_email(email)
    return head 404 if user.nil?

    return head 400 unless user.valid_password?(password)

    user.ensure_authentication_token!
    Device.register(user_params, user)

    render json: { auth_token: user.authentication_token, client_name: @client.name, email: user.email }
  end
end