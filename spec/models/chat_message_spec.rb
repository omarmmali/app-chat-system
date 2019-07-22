require 'rails_helper'

RSpec.describe ChatMessage, type: :model do
  it "returns application token and chat number when transformed to json" do
    client_application = ClientApplication.create(:name => "test_client_application")
    application_chat = client_application.chats.create

    message = application_chat.messages.create

    message_as_json = message.as_json
    expect(message_as_json[:application_token]).to eq(client_application.identifier_token)
    expect(message_as_json[:chat_number]).to eq(application_chat.identifier_number)
  end
end
