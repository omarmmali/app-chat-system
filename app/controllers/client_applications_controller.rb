class ClientApplicationsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

  def create
    client_application = ClientApplication.new(:name => client_application_params[:name])
    client_application.save
    render status: :created, json: {:application => client_application}
  end

  def show
    verify_application_token or return
    render status: :ok, json: {:application => @client_application}
  end

  def update
    verify_application_token or return
    @client_application.update(:name => client_application_params[:name])
    render status: :no_content
  end

  private

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
