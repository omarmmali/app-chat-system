require 'rails_helper'

RSpec.describe ApplicationChat, type: :model do
  it "creates an identifier number on creation" do
    client_application = ClientApplication.create(:name => "test_client_application")

    chat = client_application.chats.create

    expect(chat.identifier_number).to_not be_nil
    expect(chat.identifier_number).to eq(1)
  end
end
