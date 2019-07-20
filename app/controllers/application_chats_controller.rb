class ApplicationChatsController < ApplicationController
  def index
    application_chats = ClientApplication.find_by_identifier_token(params[:application_token]).chats
    render status: :ok, json: {:chats => application_chats}
  end
end
