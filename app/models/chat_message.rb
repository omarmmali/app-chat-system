require 'elasticsearch/model'

class ChatMessage < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :application_chat

  def as_json(options = {})
    {
        application_token: self.application_chat.client_application.identifier_token,
        chat_number: self.application_chat.identifier_number,
        number: identifier_number,
        text: text
    }
  end

  def as_indexed_json(options = {})
    {

        text: text
    }
  end
end

ChatMessage.__elasticsearch__.create_index!

ChatMessage.import