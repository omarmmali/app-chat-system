RSpec.describe "ChatMessages Search", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(name: "test_client_application")
    @application_chat = @client_application.chats.create(identifier_number: 1)
  end

  describe "Happy Scenarios" do
    describe "GET /applications/:application_token/chats/:chat_number/messages/search/:text", skip: true do
      it "returns a list of all messages where the search_term occurs", elasticsearch: true do
        chat_message_1 = @application_chat.messages.create(text: "this is some text to search for")
        chat_message_2 = @application_chat.messages.create(text: "this is some text to search for too")
        @application_chat.messages.create(:text => "this is some text")
        messages_path = messages_url_for(@client_application.identifier_token, @application_chat.identifier_number)

        get "#{messages_path}/search", params: {text: "search for"}

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
end
