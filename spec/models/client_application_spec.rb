require 'rails_helper'

RSpec.describe ClientApplication, type: :model do
  it "creates identifier token when creating application" do
    created_application = ClientApplication.create(name: 'test_application_name')

    expect(created_application.name).to eq("test_application_name")
    expect(created_application.identifier_token).to_not be_nil
    expect(created_application.identifier_token.length).to be > 10
  end
end
