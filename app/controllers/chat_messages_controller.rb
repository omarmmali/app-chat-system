require 'assets/work_queue'

class ChatMessagesController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

  def index
    verify_application_and_chat_tokens or return
    chat_messages = @parent_chat.messages
    render status: :ok, json: {messages: chat_messages}
  end

  def show
    verify_application_and_chat_tokens or return
    verify_message_number or return
    render status: :ok, json: {message: @chat_message}
  end

  def search
    verify_application_and_chat_tokens or return
    render status: :ok, json: {messages: get_all_messages_with_required_text}
  end

  def update
    verify_application_and_chat_tokens or return
    verify_message_number or return
    verify_lock_version or return

    @chat_message.assign_attributes(message_params)
    WorkQueue.enqueue_job({type: "edit", message: @chat_message})

    render status: :no_content
  end

  def create
    verify_application_and_chat_tokens or return

    parent_chat_messages = @parent_chat.messages
    WorkQueue.enqueue_job({type: "create", message: message_body(parent_chat_messages)})

    render status: :created, json: {message: message_body(parent_chat_messages)}
  end

  private

  def message_body(parent_chat_messages)
    parent_chat_messages.new(identifier_number: @parent_chat.message_count + 1, text: message_params[:text])
  end


  def get_all_messages_with_required_text
    @parent_chat.messages.search(params[:text] || '').records.to_a
  end

  def verify_lock_version
    render status: :precondition_failed and return false unless @chat_message.lock_version == message_params[:lock_version].to_i

    true
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
    params.require(:message).permit(:text, :lock_version)
  end

  def handle_error_for(invalid_parameter)
    render status: :bad_request, json: {errors: "Invalid #{invalid_parameter}"}
  end

  def handle_missing_parameter(exception)
    render status: :bad_request, json: {errors: exception.message}
  end
end
