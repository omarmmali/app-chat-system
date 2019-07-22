require 'rails_helper'
require 'bunny'

def messages_url_for(application_token, chat_number)
  "/applications/#{application_token}/chats/#{chat_number}/messages"
end

RSpec.describe "ChatMessages Unhappy Scenarios", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(name: "test_client_application")
    @application_chat = @client_application.chats.create(identifier_number: 1)
  end

  describe "GET /applications/:application_token/chats/:chat_number/messages" do
    it "returns an empty response when no messages belong to a chat" do
      get messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["messages"].length).to eq(0)
    end

    it "returns bad request when given a non existent application token" do
      get messages_url_for("non-existent_token", @application_chat.identifier_number)

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end

    it "returns bad request when given a non existent chat number" do
      get messages_url_for(@client_application.identifier_token, "non-existent_token")

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid chat number")
    end
  end

  describe "POST /applications/:application_token/chats/:chat_number/messages" do
    it "returns bad request when given a non-existent application token" do
      request_url = messages_url_for("non-existent_token", @application_chat.identifier_number)
      request_data = {message: {text: "new text"}}

      post request_url, params: request_data

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end

    it "returns bad request when given a non-existent chat number" do
      request_url = messages_url_for(@client_application.identifier_token, "non-existent_token")
      request_data = {message: {text: "new text"}}

      post request_url, params: request_data

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid chat number")
    end

    it "returns bad request when not given message text value" do
      request_url = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)
      request_data = {message: {}}

      post request_url, params: request_data

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("param is missing or the value is empty: message")
    end
  end

  describe "GET /applications/:application_token/chats/:chat_number/messages/:message_number" do
    it "returns bad request when given a non-existent application token" do
      chat_message = @application_chat.messages.create
      messages_url = messages_url_for("non-existent_token", @application_chat.identifier_number)

      get "#{messages_url}/#{chat_message.identifier_number}"

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end

    it "returns bad request when given a non-existent chat number" do
      chat_message = @application_chat.messages.create
      messages_url = messages_url_for(@client_application.identifier_token, "non-existent_token")

      get "#{messages_url}/#{chat_message.identifier_number}"

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid chat number")
    end

    it "returns bad request when given a non-existent message number" do
      messages_url = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

      get "#{messages_url}/non-existent_token"

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid message number")
    end
  end

  describe "PATCH /applications/:application_token/chats/:chat_number/messages/:message_number" do
    it "returns bad request when given a non-existent application token" do
      chat_message = @application_chat.messages.create(identifier_number: 1, text: "old text")
      messages_url = messages_url_for("non-existent_token", @application_chat.identifier_number)
      request_data = {message: {text: "new text"}}

      patch "#{messages_url}/#{chat_message.identifier_number}", params: request_data

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end

    it "returns bad request when given a non-existent chat number" do
      chat_message = @application_chat.messages.create(identifier_number: 1, text: "old text")
      messages_url = messages_url_for(@client_application.identifier_token, "non-existent_token")
      request_data = {message: {text: "new text"}}

      patch "#{messages_url}/#{chat_message.identifier_number}", params: request_data

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid chat number")
    end

    it "returns bad request when given a non-existent message number" do
      messages_url = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)
      request_data = {message: {text: "new text"}}

      patch "#{messages_url}/non-existent-token", params: request_data

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid message number")
    end
  end

  describe "GET /applications/:application_token/chats/:chat_number/messages/search/:text", elasticsearch: true, skip: true do
    it "returns an empty list when no matches are found" do
      @application_chat.messages.create(text: "this is some text to search for")
      @application_chat.messages.create(text: "this is some text to search for too")
      messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

      get "#{messages_path}/search", params: {text: "not search for"}

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["messages"].length).to eq(0)
    end

    it "returns all messages if no text is given" do
      @application_chat.messages.create(text: "this is some text to search for")
      @application_chat.messages.create(text: "this is some text to search for too")
      messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

      get "#{messages_path}/search", params: {}

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["messages"].length).to eq(2)
    end
  end
end
