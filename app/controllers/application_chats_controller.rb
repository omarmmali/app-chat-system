class ApplicationChatsController < ApplicationController
  def index
    parent_application = ClientApplication.find_by_identifier_token(params[:application_token])
    application_chats = parent_application.chats
    render status: :ok, json: {:chats => application_chats}
  end

  def create
    parent_application = ClientApplication.find_by_identifier_token(params[:application_token])

    if parent_application
      created_chat = parent_application.chats.create
      render status: :created, json: {:chat => created_chat}
    else
      render status: :bad_request, json: "Invalid application token"
    end
  end
end
