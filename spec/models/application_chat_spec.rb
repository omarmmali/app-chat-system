require 'rails_helper'

RSpec.describe ApplicationChat, type: :model do
  it "returns application token when transformed to json" do
    client_application = ClientApplication.create(name: "test_client_application")

    chat = client_application.chats.create

    chat_as_json = chat.as_json
    expect(chat_as_json[:application_token]).to eq(client_application.identifier_token)
    expect(chat_as_json[:lock_version]).to_not be_nil
    expect(chat_as_json[:message_count]).to_not be_nil
  end
end
