require 'rails_helper'

RSpec.describe "ClientApplications", type: :request do
  describe "Happy Scenarios" do
    describe "POST /applications" do
      it "creates an application" do
        application_name = "test_application_name"
        post "/applications", params: {application: {name: application_name}}

        expect(response).to have_http_status(201)
        json_response_body = JSON.parse(response.body)
        expect(json_response_body["application"]).to_not be_nil
        expect(json_response_body["application"]["id"]).to be_nil
        expect(json_response_body["application"]["name"]).to eq(application_name)
        expect(json_response_body["application"]["identifier_token"]).to_not be_nil
      end
    end

    describe "GET /applications/:application_token" do
      it "gets a client application by identifier token" do
        application_name = "test_client_application"
        current_client_application = ClientApplication.create(
            identifier_token: ClientApplication.create_identifier_token,
            name: application_name
        )

        get "/applications/#{current_client_application.identifier_token}"

        expect(response).to have_http_status(200)
        json_response_body = JSON.parse(response.body)
        expect(json_response_body["application"]).to_not be_nil
        expect(json_response_body["application"]["id"]).to be_nil
        expect(json_response_body["application"]["name"]).to eq(application_name)
        expect(json_response_body["application"]["identifier_token"]).to_not be_nil
      end
    end

    describe "PATCH /applications/:application_token" do
      it "edits a client application" do
        application_name = "test_client_application"
        current_client_application = ClientApplication.create(
            identifier_token: ClientApplication.create_identifier_token,
            name: application_name
        )

        new_application_name = "new_test_client_application"
        patch "/applications/#{current_client_application.identifier_token}", params: {:application => {:name => new_application_name}}

        expect(response).to have_http_status(204)
      end
    end
  end

  describe "Unhappy Scenarios" do
    describe "POST /applications" do
      it "not given a name" do
        post "/applications", params: {application: {name: {}}}
        expect(response).to have_http_status(400)
        expect(response.body).to eq('param is missing or the value is empty: application')
      end
    end

    describe "GET /applications/:application_token" do
      it "given a non-existent identifier_token" do
        get "/applications/non-existent_token"

        expect(response).to have_http_status(404)
        expect(response.body).to eq("no client application was found with the provided identifier token")
      end
    end

    describe "PATCH /applications/:application_token" do
      it "given a non-existent token" do
        patch "/applications/non-existent_token", params: {application: {name: "new_application_name"}}

        expect(response).to have_http_status(404)
        expect(response.body).to eq("no client application was found with the provided identifier token")
      end

      it "not given a name" do
        application_name = "test_client_application"
        current_client_application = ClientApplication.create(
            identifier_token: ClientApplication.create_identifier_token,
            name: application_name
        )

        patch "/applications/#{current_client_application.identifier_token}", params: {:application => {:name => {}}}

        expect(response).to have_http_status(400)
        expect(response.body).to eq('param is missing or the value is empty: application')
      end
    end
  end
end