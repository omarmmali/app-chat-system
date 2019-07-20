require 'rails_helper'

def messages_url_for(application_token, chat_number)
  "/applications/#{application_token}/chats/#{chat_number}/messages"
end

RSpec.describe "ChatsMessages", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(:name => "test_client_application")
    @application_chat = @client_application.chats.create
  end

  describe "Happy Scenarios" do
    describe "GET /applications/:application_token/chats/:chat_number/messages" do
      it "returns all messages that belong to a chat" do
        @application_chat.messages.create
        @application_chat.messages.create

        get messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["messages"]).to_not be_nil
        expect(json_response["messages"][0]["id"]).to be_nil
        expect(json_response["messages"][0]["number"]).to_not be_nil
        expect(json_response["messages"][1]["id"]).to be_nil
        expect(json_response["messages"][1]["number"]).to_not be_nil
        expect(json_response["messages"].length).to eq(2)
      end
    end
  end

  describe "Unhappy Scenarios" do
    describe "GET /applications/:application_token/chats/:chat_number/messages" do
      it "returns an empty response when no messages belong to a chat" do
        get messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["messages"].length).to eq(0)
      end

      it "returns bad request when given a non existent application token" do
        get messages_url_for("nonexistent_token", :ignored)

        expect(response).to have_http_status(400)
        expect(response.body).to_not be_nil
        expect(response.body).to eq("Invalid application token")
      end

      it "returns bad request when given a non existent chat number" do
        get messages_url_for(@client_application.identifier_token, "nonexistent_token")

        expect(response).to have_http_status(400)
        expect(response.body).to_not be_nil
        expect(response.body).to eq("Invalid chat number")
      end
    end
  end
end