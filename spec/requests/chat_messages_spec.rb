require 'rails_helper'

def messages_url_for(application_token, chat_number)
  "/applications/#{application_token}/chats/#{chat_number}/messages"
end

RSpec.describe "ChatMessages", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(:name => "test_client_application")
    @application_chat = @client_application.chats.create
  end

  describe "Happy Scenarios" do
    describe "GET /applications/:application_token/chats/:chat_number/messages" do
      it "returns all messages that belong to a chat" do
        @application_chat.messages.create(:text => "test text")
        @application_chat.messages.create(:text => "test text 1")

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
        request_data = {:message => {:text => "message text"}}
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
        chat_message = @application_chat.messages.create(:text => "test text")
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

    describe "PATCH /applications/:application_token/chats/:chat_number/messages" do
      it "updates the message with the given message number" do
        chat_message = @application_chat.messages.create(:text => "old text")
        request_data = {:message => {:text => "new text"}}
        messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

        patch "#{messages_path}/#{chat_message.identifier_number}", params: request_data

        expect(response).to have_http_status(204)
        chat_message.reload
        expect(chat_message.text).to eq("new text")
      end
    end

    describe "GET /applications/:application_token/chats/:chat_number/messages/search/:text", skip: true do
      it "returns a list of all messages where the search_term occurs", elasticsearch: true do
        chat_message_1 = @application_chat.messages.create(:text => "this is some text to search for")
        chat_message_2 = @application_chat.messages.create(:text => "this is some text to search for too")
        @application_chat.messages.create(:text => "this is some text")
        messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

        get "#{messages_path}/search", params: {:text => "search for"}

        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["messages"]).to_not be_nil
        expect(json_response["messages"][0]["id"]).to be_nil
        expect(json_response["messages"][0]["number"]).to eq(chat_message_1.identifier_number)
        expect(json_response["messages"][0]["text"]).to eq(chat_message_1.text)
        expect(json_response["messages"][1]["id"]).to be_nil
        expect(json_response["messages"][1]["number"]).to eq(chat_message_2.identifier_number)
        expect(json_response["messages"][1]["text"]).to eq(chat_message_2.text)
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
        request_data = {:message => {:text => "new text"}}

        post request_url, params: request_data

        expect(response).to have_http_status(400)
        expect(response.body).to_not be_nil
        expect(response.body).to eq("Invalid application token")
      end

      it "returns bad request when given a non-existent chat number" do
        request_url = messages_url_for(@client_application.identifier_token, "non-existent_token")
        request_data = {:message => {:text => "new text"}}

        post request_url, params: request_data

        expect(response).to have_http_status(400)
        expect(response.body).to_not be_nil
        expect(response.body).to eq("Invalid chat number")
      end

      it "returns bad request when not given message text value" do
        request_url = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)
        request_data = {:message => {}}

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
        chat_message = @application_chat.messages.create(:text => "old text")
        messages_url = messages_url_for("non-existent_token", @application_chat.identifier_number)
        request_data = {:message => {:text => "new text"}}

        patch "#{messages_url}/#{chat_message.identifier_number}", params: request_data

        expect(response).to have_http_status(400)
        expect(response.body).to_not be_nil
        expect(response.body).to eq("Invalid application token")
      end

      it "returns bad request when given a non-existent chat number" do
        chat_message = @application_chat.messages.create(:text => "old text")
        messages_url = messages_url_for(@client_application.identifier_token, "non-existent_token")
        request_data = {:message => {:text => "new text"}}

        patch "#{messages_url}/#{chat_message.identifier_number}", params: request_data

        expect(response).to have_http_status(400)
        expect(response.body).to_not be_nil
        expect(response.body).to eq("Invalid chat number")
      end

      it "returns bad request when given a non-existent message number" do
        messages_url = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)
        request_data = {:message => {:text => "new text"}}

        patch "#{messages_url}/non-existent-token", params: request_data

        expect(response).to have_http_status(400)
        expect(response.body).to_not be_nil
        expect(response.body).to eq("Invalid message number")
      end
    end

    describe "GET /applications/:application_token/chats/:chat_number/messages/search/:text", skip: true do
      it "returns an empty list when no matches are found" do
        @application_chat.messages.create(:text => "this is some text to search for")
        @application_chat.messages.create(:text => "this is some text to search for too")
        messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

        get "#{messages_path}/search", params: {:text => "not search for"}

        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["messages"].length).to eq(0)
      end

      it "returns all messages if no text is given" do
        @application_chat.messages.create(:text => "this is some text to search for")
        @application_chat.messages.create(:text => "this is some text to search for too")
        messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

        get "#{messages_path}/search", params: {}

        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["messages"].length).to eq(2)
      end
    end
  end
end