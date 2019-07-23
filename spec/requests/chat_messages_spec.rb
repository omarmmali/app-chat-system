require 'rails_helper'

def messages_url_for(application_token, chat_number)
  "/applications/#{application_token}/chats/#{chat_number}/messages"
end

RSpec.describe "ChatMessages Happy Scenarios", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(
        identifier_token: ClientApplication.create_identifier_token,
        name: "test_client_application"
    )
    @application_chat = @client_application.chats.create(identifier_number: 1)
  end


  describe "GET /applications/:application_token/chats/:chat_number/messages" do
    it "returns all messages that belong to a chat" do
      @application_chat.messages.create(identifier_number: 1, text: "test text")
      @application_chat.messages.create(identifier_number: 2, text: "test text 1")

      get messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["messages"]).to_not be_nil
      expect(json_response["messages"][0]["id"]).to be_nil
      expect(json_response["messages"][0]["number"]).to_not be_nil
      expect(json_response["messages"][0]["text"]).to eq("test text")
      expect(json_response["messages"][1]["id"]).to be_nil
      expect(json_response["messages"][1]["number"]).to_not be_nil
      expect(json_response["messages"][1]["text"]).to eq("test text 1")
      expect(json_response["messages"].length).to eq(2)
    end
  end

  describe "POST /applications/:application_token/chats/:chat_number/messages" do
    it "creates a message with given text" do
      request_url = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)
      request_data = {message: {text: "message text"}}
      post request_url, params: request_data

      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["message"]).to_not be_nil
      expect(json_response["message"]["id"]).to be_nil
      expect(json_response["message"]["number"]).to eq(1)
      expect(json_response["message"]["text"]).to eq("message text")
    end
  end

  describe "GET /applications/:application_token/chats/:chat_number/messages/:message_number" do
    it "returns the message with the given message number" do
      chat_message = @application_chat.messages.create(identifier_number: 1, text: "test text")
      messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

      get "#{messages_path}/#{chat_message.identifier_number}"

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["message"]).to_not be_nil
      expect(json_response["message"]["id"]).to be_nil
      expect(json_response["message"]["number"]).to eq(1)
      expect(json_response["message"]["text"]).to eq("test text")
    end
  end

  describe "PATCH /applications/:application_token/chats/:chat_number/messages/:message_number" do
    it "updates the message with the given message number" do
      chat_message = @application_chat.messages.create(identifier_number: 1, text: "old text")
      request_data = {message: {text: "new text", lock_version: chat_message.lock_version}}
      messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

      patch "#{messages_path}/#{chat_message.identifier_number}", params: request_data

      expect(response).to have_http_status(204)
    end
  end
end