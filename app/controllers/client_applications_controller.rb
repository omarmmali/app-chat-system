class ClientApplicationsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

  def create
    client_application = ClientApplication.new(:name => client_application_params)
    client_application.save
    render status: :created, json: {:application => client_application}
  end

  def show
    client_application = ClientApplication.find_by_identifier_token(params[:application_token])
    handle_entity_not_found and return unless client_application
    render status: :ok, json: {:application => client_application}
  end

  def update
    client_application = ClientApplication.find_by_identifier_token(params[:application_token])
    handle_entity_not_found and return unless client_application

    client_application.update(:name => client_application_params)
    render status: :no_content
  end

  private

  def handle_entity_not_found
    render status: :not_found, json: "no client application was found with the provided identifier token"
  end

  def handle_missing_parameter(exception)
    render status: :bad_request, json: exception.message
  end

  def client_application_params
    params.require(:name)
  end
end
