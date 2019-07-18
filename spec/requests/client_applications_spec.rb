require 'rails_helper'

RSpec.describe "ClientApplications", type: :request do
  describe "GET /applications" do
    it "gets all client applications" do
      application_name = "test_applications_name"
      ClientApplication.create(:name => application_name)
      ClientApplication.create(:name => application_name)

      get "/applications"

      expect(response).to have_http_status(200)
      json_response_body = JSON.parse(response.body)
      expect(json_response_body["applications"]).to_not be_nil
      expect(json_response_body["applications"].length).to eq(2)
      expect(json_response_body["applications"][0]["id"]).to be_nil
    end
  end

  describe "POST /applications" do
    it "creates an application" do
      application_name = "test_application_name"
      post "/applications", params: {:name => application_name}

      expect(response).to have_http_status(201)
      json_response_body = JSON.parse(response.body)
      expect(json_response_body["application"]).to_not be_nil
      expect(json_response_body["application"]["id"]).to be_nil
      expect(json_response_body["application"]["name"]).to eq(application_name)
      expect(json_response_body["application"]["identifier_token"]).to_not be_nil
    end
  end

  describe "GET /applications/:token" do
    it "gets a client application by identifier token" do
      application_name = "test_client_application"
      current_client_application = ClientApplication.create(:name => application_name)

      get "/applications/#{current_client_application.identifier_token}"

      expect(response).to have_http_status(200)
      json_response_body = JSON.parse(response.body)
      expect(json_response_body["application"]).to_not be_nil
      expect(json_response_body["application"]["id"]).to be_nil
      expect(json_response_body["application"]["name"]).to eq(application_name)
      expect(json_response_body["application"]["identifier_token"]).to_not be_nil
    end
  end

  describe "PATCH /applications/:token" do
    it "edits a client application" do
      application_name = "test_client_application"
      current_client_application = ClientApplication.create(:name => application_name)

      new_application_name = "new_test_client_application"
      patch "/applications/#{current_client_application.identifier_token}", params: {:name => new_application_name}

      expect(response).to have_http_status(204)
      current_client_application.reload
      expect(current_client_application.name).to eq(new_application_name)
    end
  end
end

RSpec.describe "ClientApplications Unhappy Scenarios", type: :request do
  describe "GET /applications" do
    it "no applications exist" do
      get "/applications"

      expect(response).to have_http_status(200)
      json_response_body = JSON.parse(response.body)
      expect(json_response_body["applications"]).to_not be_nil
      expect(json_response_body["applications"].length).to eq(0)
    end
  end

  describe "POST /applications" do
    it "not given a name" do
      post "/applications", params: {}
      expect(response).to have_http_status(400)
      expect(response.body).to eq('param is missing or the value is empty: name')
    end
  end

  describe "GET /applications/:token" do
    it "given a nonexistent identifier_token" do
      get "/applications/nonexistent_token"

      expect(response).to have_http_status(404)
      expect(response.body).to eq("no client application was found with the provided identifier token")
    end
  end

  describe "PATCH /applications/:token" do
    it "given a nonexistent token" do
      patch "/applications/nonexistent_token", params: {:name => "new_application_name"}

      expect(response).to have_http_status(404)
      expect(response.body).to eq("no client application was found with the provided identifier token")
    end

    it "not given a name" do
      application_name = "test_client_application"
      current_client_application = ClientApplication.create(:name => application_name)

      patch "/applications/#{current_client_application.identifier_token}", params: {}

      expect(response).to have_http_status(400)
      expect(response.body).to eq('param is missing or the value is empty: name')
    end
  end
end