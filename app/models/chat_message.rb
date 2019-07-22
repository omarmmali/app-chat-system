require 'elasticsearch/model'

class ChatMessage < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :application_chat

  before_create :generate_identifier_number

  def as_json(options = {})
    {
        :number => identifier_number,
        :text => text
    }
  end

  def as_indexed_json(options = {})
    {

        text: text
    }
  end

  private

  def generate_identifier_number
    self.identifier_number = self.application_chat.messages.count + 1
  end
end

ChatMessage.__elasticsearch__.create_index!

ChatMessage.import