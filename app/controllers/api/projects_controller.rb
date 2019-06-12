class Api::ProjectsController < Api::ApplicationController
  def index
    projects = current_user.projects

    logger.info projects.inspect

    render json: projects.all
  end

  def create
    project = current_user.projects.build(project_params)
    project.save!
    render json: {project: project}
  end

  protected
    def project_params
      params.require(:project).permit(:name, :screen_of_records, :screen_of_editions, :screen_of_searchs, :reports, :print_of_documents, :send_of_messages, :automatic_routines, :external_database_tables)
    end
end