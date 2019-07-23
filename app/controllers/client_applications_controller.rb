class ClientApplicationsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

  def create
    WorkQueue.enqueue_job({type: "create", application: application_body})
    render status: :created, json: {application: application_body}
  end

  def show
    verify_application_token or return
    render status: :ok, json: {application: @client_application}
  end

  def update
    verify_application_token or return

    @client_application.assign_attributes(name: client_application_params[:name])
    WorkQueue.enqueue_job({type: "edit", application: @client_application})

    render status: :no_content
  end

  private

  def application_body
    ClientApplication.new(name: client_application_params[:name], identifier_token: ClientApplication.create_identifier_token)
  end

  def verify_application_token
    @client_application = ClientApplication.find_by_identifier_token(params[:token])
    handle_entity_not_found and return false unless @client_application

    true
  end

  def handle_entity_not_found
    render status: :not_found, json: "no client application was found with the provided identifier token"
  end

  def handle_missing_parameter(exception)
    render status: :bad_request, json: exception.message
  end

  def client_application_params
    params.require(:application).permit(:name)
  end
end
