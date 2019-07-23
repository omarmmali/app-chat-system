require 'rails_helper'

def chats_url_for(application_token)
  "/applications/#{application_token}/chats"
end

RSpec.describe "ClientApplicationsChats Unhappy Scenarios", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(name: "test_client_application")
  end

  describe "GET /applications/:application_token/chats" do
    it "returns an empty response when client application has no chats" do
      get chats_url_for(@client_application.identifier_token)

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["chats"].length).to eq(0)
    end

    it "returns bad request when given a non existent application token" do
      get chats_url_for("non-existent_token")

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end
  end

  describe "GET /applications/:application_token/chats/:chat_number" do
    it "returns bad request when given a non existent application token" do
      application_chat = @client_application.chats.create(identifier_number: 1, modifiable_attribute: "old value")

      get "#{chats_url_for("non-existent_token")}/#{application_chat.identifier_number}"

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end

    it "returns bad request when given a non existent chat number" do
      @client_application.chats.create(identifier_number: 1, modifiable_attribute: "old value")

      get "#{chats_url_for(@client_application.identifier_token)}/non-existent_number"

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid chat number")
    end
  end

  describe "POST /applications/:application_token/chats" do
    it "returns bad request when given a non-existent application token" do
      post chats_url_for("non-existent_token")

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end
  end

  describe "PATCH /applications/:application_token/chats/:chat_number" do
    it "returns bad request when given a non existent application token" do
      application_chat = @client_application.chats.create(identifier_number: 1, modifiable_attribute: "old value")
      request_body = {chat: {modifiable_attribute: "new value"}}
      patch "#{chats_url_for("non-existent_token")}/#{application_chat.identifier_number}", params: request_body

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid application token")
    end

    it "returns bad request when given a non existent chat number" do
      @client_application.chats.create(identifier_number: 1, modifiable_attribute: "old value")
      request_body = {chat:{modifiable_attribute: "new value"}}
      patch "#{chats_url_for(@client_application.identifier_token)}/non-existent_number", params: request_body

      expect(response).to have_http_status(400)
      expect(response.body).to_not be_nil
      expect(response.body).to eq("Invalid chat number")
    end
  end
end