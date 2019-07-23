require 'assets/work_queue'

class ApplicationChatsController < ApplicationController
  def index
    verify_application_token or return
    application_chats = @parent_application.chats
    render status: :ok, json: {chats: application_chats}
  end

  def create
    verify_application_token or return
    parent_chats = @parent_application.chats

    WorkQueue.enqueue_job({type: "create", chat: chat_body(parent_chats)})

    render status: :created, json: {chat: chat_body(parent_chats)}
  end

  def update
    verify_application_token or return
    verify_chat_number or return
    verify_lock_version or return

    @application_chat.assign_attributes(chat_params)
    WorkQueue.enqueue_job({type: "edit", chat: @application_chat})

    render status: :no_content
  end

  def show
    verify_application_token or return
    verify_chat_number or return
    render status: :ok, json: {chat: @application_chat}
  end

  private

  def verify_lock_version
    render status: :precondition_failed and return false unless @application_chat.lock_version == chat_params[:lock_version].to_i

    true
  end

  def chat_body(parent_chats)
    parent_chats.new(identifier_number: parent_chats.count + 1)
  end


  def verify_application_token
    @parent_application = ClientApplication.find_by_identifier_token(params[:client_application_token])
    handle_error_for("application token") and return false unless @parent_application

    true
  end

  def verify_chat_number
    @application_chat = @parent_application.chats.find_by(:identifier_number => params[:number])
    handle_error_for("chat number") and return false unless @application_chat

    true
  end

  def handle_error_for(invalid_parameter)
    render status: :bad_request, json: "Invalid #{invalid_parameter}"
  end

  def chat_params
    params.require(:chat).permit(:modifiable_attribute, :lock_version)
  end

end
