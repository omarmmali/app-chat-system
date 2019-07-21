class ChatMessagesController < ApplicationController
  def index
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return unless parent_application

    parent_chat = parent_application.chats.find_by(:identifier_number => params[:application_chat_number])
    handle_error_for("chat number") and return unless parent_chat

    chat_messages = parent_chat.messages
    render status: :ok, json: {:messages => chat_messages}
  end

  def show
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return unless parent_application

    parent_chat = parent_application.chats.find_by(:identifier_number => params[:application_chat_number])
    handle_error_for("chat number") and return unless parent_chat

    chat_message = parent_chat.messages.find_by(:identifier_number => params[:number])
    handle_error_for("message number") and return unless chat_message

    render status: :ok, json: {:message => chat_message}
  end

  def update
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return unless parent_application

    parent_chat = parent_application.chats.find_by(:identifier_number => params[:application_chat_number])
    handle_error_for("chat number") and return unless parent_chat

    chat_message = parent_chat.messages.find_by(:identifier_number => params[:number])
    handle_error_for("message number") and return unless chat_message

    chat_message.update(message_params)
    render status: :no_content
  end

  def create
    parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    parent_chat = parent_application.chats.find_by(:identifier_number => params[:application_chat_number])
    chat_message = parent_chat.messages.create(:text => message_params[:text])
    render status: :created, json: {:message => chat_message}
  end

  private

  def message_params
    params.require(:message).permit(:text)
  end

  def handle_error_for(invalid_parameter)
    render status: :bad_request, json: "Invalid #{invalid_parameter}"
  end

end
