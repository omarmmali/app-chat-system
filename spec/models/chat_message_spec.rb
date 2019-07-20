require 'rails_helper'

RSpec.describe ChatMessage, type: :model do
  it "creates an identifier number on creation" do
    client_application = ClientApplication.create(:name => "test_client_application")
    application_chat = client_application.chats.create

    message = application_chat.messages.create

    expect(message.identifier_number).to_not be_nil
    expect(message.identifier_number).to eq(1)
  end
end
