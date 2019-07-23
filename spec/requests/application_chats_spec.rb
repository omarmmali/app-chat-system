require 'rails_helper'

def chats_url_for(application_token)
  "/applications/#{application_token}/chats"
end

RSpec.describe "ClientApplicationsChats Happy Scenarios", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(
        name: "test_client_application",
        identifier_token: ClientApplication.create_identifier_token
    )
  end

  describe "GET /applications/:application_token/chats" do
    it "returns all chats that belong to an application" do
      @client_application.chats.create(identifier_number: 1)
      @client_application.chats.create(identifier_number: 2)

      get chats_url_for(@client_application.identifier_token)

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["chats"]).to_not be_nil
      expect(json_response["chats"][0]["id"]).to be_nil
      expect(json_response["chats"][0]["number"]).to_not be_nil
      expect(json_response["chats"][1]["id"]).to be_nil
      expect(json_response["chats"][1]["number"]).to_not be_nil
      expect(json_response["chats"].length).to eq(2)
    end
  end

  describe "GET /applications/:application_token/chats/:chat_number" do
    it "returns the chat with the given chat number" do
      application_chat = @client_application.chats.create(identifier_number: 1)

      get "#{chats_url_for(@client_application.identifier_token)}/#{application_chat.identifier_number}"

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["chat"]).to_not be_nil
      expect(json_response["chat"]["id"]).to be_nil
      expect(json_response["chat"]["number"]).to eq(1)
    end
  end

  describe "POST /applications/:application_token/chats" do
    it "creates a chat for the given application" do
      post chats_url_for(@client_application.identifier_token)

      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["chat"]).to_not be_nil
      expect(json_response["chat"]["id"]).to be_nil
      expect(json_response["chat"]["number"]).to eq(1)
    end
  end

  describe "PATCH /applications/:application_token/chats/:chat_number" do
    it "updates chat" do
      application_chat = @client_application.chats.create(identifier_number: 1, modifiable_attribute: "old value")
      request_body = {chat: {modifiable_attribute: "new value"}}

      patch "#{chats_url_for(@client_application.identifier_token)}/#{application_chat.identifier_number}", params: request_body

      expect(response).to have_http_status(204)
    end
  end
end