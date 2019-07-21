class ChatMessagesController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

  def index
    verify_application_and_chat_tokens or return
    chat_messages = @parent_chat.messages
    render status: :ok, json: {:messages => chat_messages}
  end

  def show
    verify_application_and_chat_tokens or return
    verify_message_number or return
    render status: :ok, json: {:message => @chat_message}
  end

  def search
    verify_application_and_chat_tokens or return
    chat_messages_with_required_text = get_all_messages_with_required_text
    render status: :ok, json: {:messages => chat_messages_with_required_text}
  end

  def update
    verify_application_and_chat_tokens or return
    verify_message_number or return
    @chat_message.update(message_params)
    render status: :no_content
  end

  def create
    verify_application_and_chat_tokens or return
    chat_message = @parent_chat.messages.create(:text => message_params[:text])
    render status: :created, json: {:message => chat_message}
  end

  private

  def get_all_messages_with_required_text
    ChatMessage.all.collect do |message|
      message if message.text.include? params[:text]
    end
  end

  def verify_message_number
    @chat_message = @parent_chat.messages.find_by(:identifier_number => params[:number])
    handle_error_for("message number") and return false unless @chat_message

    true
  end

  def verify_application_and_chat_tokens
    @parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return false unless @parent_application

    @parent_chat = @parent_application.chats.find_by(:identifier_number => params[:application_chat_number])
    handle_error_for("chat number") and return false unless @parent_chat

    true
  end

  def message_params
    params.require(:message).permit(:text)
  end

  def handle_error_for(invalid_parameter)
    render status: :bad_request, json: "Invalid #{invalid_parameter}"
  end

  def handle_missing_parameter(exception)
    render status: :bad_request, json: exception.message
  end
end
