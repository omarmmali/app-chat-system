require 'rails_helper'

RSpec.describe "ClientApplications", type: :request do
  describe "GET /applications" do
    it "get client application" do
      ClientApplication.create(:name => 'test_applications_name')
      ClientApplication.create(:name => 'test_applications_name')

      get '/applications'

      expect(response).to have_http_status(200)

      json_response_body = JSON.parse(response.body)
      expect(json_response_body["applications"]).to_not be_nil
      expect(json_response_body["applications"].length).to eq(2)
      expect(json_response_body["applications"][0]["id"]).to be_nil
    end
  end
end
