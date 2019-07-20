class ChatMessagesController < ApplicationController
  def index
    parent_application = ClientApplication.find_by_identifier_token(params[:application_token])
    handle_invalid_app_token and return unless parent_application

    parent_chat = parent_application.chats.find_by(:identifier_number => params[:chat_number])
    handle_invalid_chat_number and return unless parent_chat

    chat_messages = parent_chat.messages
    render status: :ok, json: {:messages => chat_messages}
  end

  private

  def handle_invalid_chat_number
    render status: :bad_request, json: "Invalid chat number"
  end

  def handle_invalid_app_token
    render status: :bad_request, json: "Invalid application token"
  end

end
