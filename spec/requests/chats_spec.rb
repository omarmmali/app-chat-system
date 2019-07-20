require 'rails_helper'

RSpec.describe "ClientApplicationsChats", type: :request do
  describe "GET /applications/:application_token/chats" do
    it "should return all chats that belong to an application" do
      client_application = ClientApplication.create(:name => 'test_client_application')
      client_application.chats.create
      client_application.chats.create

      get "/applications/#{client_application.identifier_token}/chats"

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["chats"]).to_not be_nil
      expect(json_response["chats"][0]["id"]).to be_nil
      expect(json_response["chats"][0]["number"]).to_not be_nil
      expect(json_response["chats"][1]["id"]).to be_nil
      expect(json_response["chats"][1]["number"]).to_not be_nil
      expect(json_response["chats"].length).to eq(2)
    end
  end
end