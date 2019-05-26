class Api::ProjectsController < Api::ApplicationController
  def index
    projects = current_user.projects

    logger.info projects.inspect

    render json: projects.all
  end
end