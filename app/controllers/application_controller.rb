class ApplicationController < ActionController::Base
  layout 'devise_layout', if: :devise_controller?
end
