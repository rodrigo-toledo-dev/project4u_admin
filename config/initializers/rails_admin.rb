RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show

    config.model 'User' do
      list do
        field :id
        field :name
        field :email
        field :password
        field :password_confirmation
        field :created_at
      end
  
      edit do
        field :name
        field :email
        field :password
        field :password_confirmation
      end
    end

    config.model 'Client' do
      list do
        field :id
        field :name
        field :created_at
        field :updated_at
      end
    end

    config.model 'Project' do
      show do
        configure :formula_1 do
        end
      end
    end
  end
end
