require 'rails_helper'

def chats_url_for(application_token)
  "/applications/#{application_token}/chats"
end

def create_empty_queue
  @connection = Bunny.new(hostname: 'rabbitmq:5672').start
  @channel = @connection.create_channel
  @queue = @channel.queue('jobs')
  @queue.purge
end

RSpec.describe "ClientApplicationsChats Happy Scenarios", type: :request do
  before(:each) do
    @client_application = ClientApplication.create(:name => "test_client_application")
  end

  describe "GET /applications/:application_token/chats" do
    it "returns all chats that belong to an application" do
      @client_application.chats.create(identifier_number: 1)
      @client_application.chats.create(identifier_number: 2)

      get chats_url_for(@client_application.identifier_token)

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

  describe "GET /applications/:application_token/chats/:chat_number" do
    it "returns the chat with the given chat number" do
      application_chat = @client_application.chats.create(identifier_number: 1)

      get "#{chats_url_for(@client_application.identifier_token)}/#{application_chat.identifier_number}"

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response["chat"]).to_not be_nil
      expect(json_response["chat"]["id"]).to be_nil
      expect(json_response["chat"]["number"]).to eq(1)
    end
  end

  describe "POST /applications/:application_token/chats" do
    before(:each) do
      @connection = Bunny.new(hostname: 'rabbitmq:5672').start
      @channel = @connection.create_channel
      @queue = @channel.queue('jobs')
      @queue.purge
    end

    after(:each) do
      @connection.close
    end

    it "creates a chat for the given application" do
      post chats_url_for(@client_application.identifier_token)

      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["chat"]).to_not be_nil
      expect(json_response["chat"]["id"]).to be_nil
      expect(json_response["chat"]["number"]).to eq(1)
    end

    it "sends create chat request to work queue" do
      post chats_url_for(@client_application.identifier_token)

      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response["chat"]).to_not be_nil
      expect(json_response["chat"]["id"]).to be_nil
      expect(json_response["chat"]["application_token"]).to eq(@client_application.identifier_token)
      expect(json_response["chat"]["number"]).to eq(1)
      expect(@queue.message_count).to eq(1)
      _, _, queued_message = @queue.pop
      queued_message = JSON.parse(queued_message)
      expect(queued_message["chat"]["application_token"]).to eq(@client_application.identifier_token)
      expect(queued_message["chat"]["number"]).to eq(1)
      expect(queued_message["type"]).to eq("create")
    end
  end

  describe "PATCH /applications/:application_token/chats/:chat_number" do
    before(:each) {create_empty_queue}

    after(:each) {@connection.close}

    it "updates chat" do
      application_chat = @client_application.chats.create(identifier_number: 1, modifiable_attribute: "old value")
      request_body = {chat: {modifiable_attribute: "new value"}}

      patch "#{chats_url_for(@client_application.identifier_token)}/#{application_chat.identifier_number}", params: request_body

      expect(response).to have_http_status(204)
    end

    it "sends edit chat request to work queue" do
      application_chat = @client_application.chats.create(identifier_number: 1, modifiable_attribute: "old value")
      request_body = {chat: {modifiable_attribute: "new value"}}

      patch "#{chats_url_for(@client_application.identifier_token)}/#{application_chat.identifier_number}", params: request_body

      expect(response).to have_http_status(204)
      expect(@queue.message_count).to eq(1)
      _, _, queued_message = @queue.pop
      queued_message = JSON.parse(queued_message)
      expect(queued_message["chat"]["application_token"]).to eq(@client_application.identifier_token)
      expect(queued_message["chat"]["number"]).to eq(1)
      expect(queued_message["type"]).to eq("edit")
    end
  end
end