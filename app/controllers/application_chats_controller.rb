class ApplicationChatsController < ApplicationController
  def index
    parent_application = ClientApplication.find_by_identifier_token(params[:application_token])
    application_chats = parent_application.chats
    render status: :ok, json: {:chats => application_chats}
  end

  def create
    parent_application = ClientApplication.find_by_identifier_token(params[:application_token])
    handle_invalid_app_token and return unless parent_application

    created_chat = parent_application.chats.create
    render status: :created, json: {:chat => created_chat}
  end

  def update
    parent_application = ClientApplication.find_by_identifier_token(params[:application_token])
    handle_invalid_app_token and return unless parent_application

    application_chat = parent_application.chats.find_by(:identifier_number => params[:chat_number])
    handle_invalid_chat_number and return unless application_chat

    application_chat.update(chat_params)
    render status: :no_content
  end

  private

  def handle_invalid_chat_number
    render status: :bad_request, json: "Invalid chat number"
  end

  def handle_invalid_app_token
    render status: :bad_request, json: "Invalid application token"
  end

  def chat_params
    params.require(:chat).permit(:modifiable_attribute)
  end

end
