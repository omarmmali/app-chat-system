require 'securerandom'

class ClientApplication < ApplicationRecord
  alias_attribute :chats, :application_chats

  has_many :application_chats

  def self.create_identifier_token
    SecureRandom.urlsafe_base64(10)
  end


  def as_json(options = {})
    {
        name: name,
        identifier_token: identifier_token,
        created_at: created_at,
        updated_at: updated_at,
        chat_count: chat_count
    }
  end
end
