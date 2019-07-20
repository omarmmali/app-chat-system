class ApplicationChatsController < ApplicationController
  def index
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return unless parent_application

    application_chats = parent_application.chats
    render status: :ok, json: {:chats => application_chats}
  end

  def create
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return unless parent_application

    created_chat = parent_application.chats.create
    render status: :created, json: {:chat => created_chat}
  end

  def update
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return unless parent_application

    application_chat = parent_application.chats.find_by(:identifier_number => params[:number])
    handle_error_for("chat number") and return unless application_chat

    application_chat.update(chat_params)
    render status: :no_content
  end

  def show
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return unless parent_application

    application_chat = parent_application.chats.find_by(:identifier_number => params[:number])
    handle_error_for("chat number") and return unless application_chat

    render status: :ok, json: {:chat => application_chat}
  end

  private

  def handle_error_for(invalid_parameter)
    render status: :bad_request, json: "Invalid #{invalid_parameter}"
  end

  def chat_params
    params.require(:chat).permit(:modifiable_attribute)
  end

end
