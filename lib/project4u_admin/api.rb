# encoding: utf-8

module Project4uAdmin
  class API < Grape::API
    version 'v1', :using => :header, :vendor => 'project4u_admin'

    format :json
    # error_format :json
    default_format :json

    logger Rails.logger

    rescue_from ActiveRecord::RecordNotFound do |e|
      rack_response('', 404)
    end

    helpers do
      def logger
        Rails.logger
      end

      def current_user
        return nil if params[:auth_token].blank?
        @current_user ||= User.find_by_authentication_token(params[:auth_token])
      end

      def unauthorized!
        error!('401 Unauthorized', 401)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end

      def wrong_email_and_or_password!
        error!('401 E-mail and/or password is wrong', 401)
      end

      def user_missing_params!(errors)
        error!("401 User invalid params #{errors}", 401)
      end

      def user_already_registered!
        error!('401 User already registered', 401)
      end

      def not_found!
        error!('404 Not found', 404)
      end

      def verify_and_update_version!
        appversion = params[:app_version]
        if not appversion.blank? and current_user
          device = current_user.device
          begin
            device.update_appversion!(appversion) if device
          rescue
            # do nothing
          end
        end
      end
    end

    before do
      # verify_and_update_version!
    end

    #
    # API Authetication
    resource :users do
      desc 'Sign UP user returning a new auth token'
      params do
        requires :first_name, type: String, desc: 'First name'
        requires :last_name, type: String, desc: 'Last name'
        requires :email, type: String, desc: 'Email'
        requires :client_name, type: String, desc: 'Client'
        requires :password, type: String, desc: 'Password'
        requires :password_confirmation, type: String, desc: 'Password confirmation'
        requires :uuid, type: String
        requires :gcm_reg_id, type: String
      end
      post '/sign_up' do
        email, password, uuid = params[:email], params[:password], params[:uuid]
        user = User.find_by_email(email.downcase)
        if user
          Device.register(params, user)
          user_already_registered!
        end

        client = Client.find_by_name(params[:client_name])
        not_found! unless client
        
        user = client.users.build(
          first_name: params[:first_name],
          last_name: params[:last_name],
          email: params[:email],
          password: params[:password],
          password_confirmation: params[:password_confirmation],
        )
        user_missing_params!(user.errors.full_messages.to_sentence) unless user.save
        user.ensure_authentication_token!
        Device.register(params, user)

        { auth_token: user.authentication_token }
      end

      desc 'Sign in user returning a new auth token'
      params do
        requires :email, type: String, desc: 'user name/email'
        requires :password, type: String, desc: 'password'
        requires :device_uuid, type: String
      end
      post '/sign_in' do
        email, password = params[:email], params[:password]
        # user = User.find_by_email(email.downcase)
        user = User.find_by_email(email.downcase)
        wrong_email_and_or_password! if user.nil?

        user.ensure_authentication_token!
        wrong_email_and_or_password! if not user.valid_password?(password)

        uuid = params[:device_uuid]
        Device.find_or_initialize_by(uuid: uuid) do |device|
          device.user = user
          device.save(validate: false)
        end

        { auth_token: user.authentication_token }
      end

      desc 'Sign out user from matching token'
      params do
        requires :auth_token, type: String, desc: 'authentication token'
      end
      post '/sign_out' do
        user = User.find_by_authentication_token(params[:auth_token])
        not_found! if user.nil?

        user.reset_authentication_token!
      end
    end

    #
    # Jobs
    resources :jobs do
      desc 'List a opened/available jobs to a user identified by our auth token'
      params do
        requires :auth_token, type: String
      end
      get '/' do
        authenticate!

        @jobs = Job.opened.assigned_to_user(current_user)

        account = @current_account
        if account.module == 'agt' or account.module == 'agt2'
          present @jobs.map{ |j| j.extend(Extensions::Agt::JobExtensions) }, :with => RablPresenter, :source => "api/jobs/agt/index"
        elsif account.module == 'tesb' or account.module == 'tesb_provider'
          present @jobs.map{ |j| j.extend(Extensions::Tesb::JobExtensions) }, :with => RablPresenter, :source => "api/jobs/tesb/index"
        elsif account.module == 'allarmi' or account.module == 'allarmi_provider'
          present @jobs.map{ |j| j.extend(Extensions::Allarmi::JobExtensions) }, :with => RablPresenter, :source => "api/jobs/tesb/index"
        elsif account.module == 'fenix' or account.module == 'fenix_provider'
          present @jobs.map{ |j| j.extend(Extensions::Fenix::JobExtensions) }, :with => RablPresenter, :source => "api/jobs/fenix/index"
        elsif account.module == 'sothis'
          present @jobs.map{ |j| j.extend(Extensions::Sothis::JobExtensions) }, :with => RablPresenter, :source => "api/jobs/sothis/index"
        elsif account.module == 'proxer_telecom'
          present @jobs.map{ |j| j.extend(Extensions::ProxerTelecom::JobExtensions) }, :with => RablPresenter, :source => "api/jobs/proxer_telecom/index"
        elsif account.module == 'w4m'
          present @jobs.map{ |j| j.extend(Extensions::W4m::JobExtensions) }, :with => RablPresenter, :source => "api/jobs/w4m/index"
        else
          present @jobs, :with => RablPresenter, :source => "api/jobs/index"
        end
      end

      # desc 'Update a job with a posted feedback'
      # params do
      #   requires :auth_token, type: String
      #   group :activity do
      #     requires :job_id
      #     requires :close_job
      #     requires :solved_job
      #     requires :document
      #     requires :occurred_at
      #     optional :reason
      #     optional :latitude
      #     optional :longitude
      #     optional :description
      #   end
      # end

      #
      # TODO: Don't reply 404 when job is not found, reply 422 instead!
      post '/update' do
        authenticate!
        not_found! if not params[:activity].has_key?(:job_id)

        job_id      = params[:activity][:job_id]
        latitude    = params[:activity][:latitude]
        longitude   = params[:activity][:longitude]
        occurred_at = DateTime.parse(params[:activity][:occurred_at]).utc
        document    = params[:activity][:document]
        close_job   = params[:activity][:close_job]
        solved_job  = params[:activity][:solved_job]
        reason      = params[:activity][:reason]

        job = Job.find(job_id)

        # If the document has a custom_status, so I want to try to find
        # a status if given custom status.
        next_status = nil
        activity_type = 'none'
        parsed_document = JSON.parse(document)
        if parsed_document['custom_status']
          next_status = Status.where(account_id: (job.owner_id || job.account_id)).find_by_name(parsed_document['custom_status'])
        end

        if next_status.nil?
          if solved_job == "true"
            description = "Realizou o serviço"
            activity_type = 'solved'
          else
            description = "Não realizou o serviço"
            activity_type = 'not_solved'
          end
        else
          description = "Atualizou o status para #{next_status.to_s}"
          activity_type = next_status.type
        end

        Job.transaction do
          if params[:app_version]
            job.update_rat_version!(params[:app_version])
          else
            job.update_rat_version!("1.0.9")
          end

          job_belongs_to_the_user = current_user.id == job.assigned_to
          if not job_belongs_to_the_user
            description = "#{description} - Ignorado. Serviço não pertence ao operador."
          end

          # record activity anyway.
          job.activities.build(user: current_user,
                               type: activity_type,
                               occurred_at: occurred_at,
                               latitude: latitude,
                               longitude: longitude,
                               description: description,
                               account_id: job.account_id)

          job.update_response_document(document)

          # just if it belongs to the user.
          if job_belongs_to_the_user
            if next_status.nil?
              job.status = Status.default_closed_status if close_job
            else
              job.status = next_status
            end

            # remove the assignment to the user if the
            # status tell us to do it.
            if next_status and next_status.unassign?
              job.assigned_to = nil
            end

            job.solved = solved_job # => true/false
            begin
              job.fix_closed_at!
            rescue
            end

            begin
              job.sync_job_name!
            rescue
            end

            begin
              job.update_job_products!
              job.enqueue_update_job_products!
            rescue
            end
          end

          # save it to record the activities.
          job.save!(validate:false)

          true
        end
      end

      post '/:job_id/send_email' do
        job = Job.find(params[:job_id])
        email = params[:email]
        logger.info "Enviando RAT #{job.id} para e-mail #{email}"
        if not email.blank?
          begin
            AgtRatMailer.rat_for_signature_email(email, job).deliver
            true
          rescue
            false
          end
        else
          raise "Nao foi possivel enviar OS ##{job.id} em PDF. E-mail: #{email}."
        end
      end
    end

    #
    # Possible reasons of a not to do a designated job.
    resources :lists do
      get '/products' do
        if @current_account.name == 'allarmi' or @current_account.name == 'tesb'
          user_products = UserProduct.where(user_id: current_user.id)
            .joins(:product)
            .where('available_quantity > 0')
            .where(products: { deleted_at: nil })
            .order(:name)
          user_products.map do |up|
            p = up.product
            {
              code: p.id,
              value: p.full_name,
              quantity_available: up.available_quantity,
              sub_group_id: p.sub_group_id,
              sub_group_name: p.sub_group.try(:name),
              user_product: up.id,
              customer_type: p.customer_type
            }
          end
        else
          products = Product.of_account(@current_account).where(deleted_at: nil).order(:name)
          products.map do |p|
            {
              code: p.id,
              value: p.full_name,
              sub_group_id: p.sub_group_id,
              sub_group_name: p.sub_group.try(:name)
            }
          end
        end
      end
      get '/:name' do
        list = List.of_account(@current_account).find_by_name(params[:name])
        if list
          list.list_items.map do |item|
            { code: item.code, value: item.value }
          end.to_json
        else
          [].to_json
        end
      end
    end

    #
    # Possible reasons of a not to do a designated job.
    resources :solutions do
      get '/' do
        Option.of_solutions.map do |s|
          { id: s.id, name: s.name }
        end.to_json
      end
    end

    resources :reasons do
      get '/' do
        Option.of_reasons.map do |s|
          { id: s.id, name: s.name }
        end.to_json
      end
    end

    #
    # Device registration
    resources :devices do
      params do
        group :device, type: JSON do
          requires :uuid
          requires :gcm_reg_id
        end
      end
      post '/' do
        uuid, gcm_reg_id = params[:device][:uuid], params[:device][:gcm_reg_id]
        Device.find_or_initialize_by(uuid: uuid, account_id: @current_account.id) do |device|
          device.gcm_reg_id = gcm_reg_id
          device.save
        end
      end
    end

  end
end
