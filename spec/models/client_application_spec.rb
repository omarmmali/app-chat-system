require 'rails_helper'

RSpec.describe ClientApplication, type: :model do
 describe "create_identifier_token" do
   it "creates identifier token" do
     created_application = ClientApplication.create(identifier_token: ClientApplication.create_identifier_token, name: 'test_application_name')

     expect(created_application.name).to eq("test_application_name")
     expect(created_application.identifier_token).to_not be_nil
     expect(created_application.identifier_token.length).to be > 10
   end
 end
  it "returns chat count when transformed to json" do
    created_application = ClientApplication.create(identifier_token: ClientApplication.create_identifier_token, name: 'test_application_name')
    json_client_application = created_application.as_json
    expect(json_client_application[:chat_count]).to_not be_nil
  end
end
