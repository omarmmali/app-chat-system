require 'securerandom'

class ClientApplication < ApplicationRecord
  alias_attribute :chats, :application_chats

  before_create :create_identifier_token
  has_many :application_chats

  def create_identifier_token
    self.identifier_token = SecureRandom.urlsafe_base64(10)
  end


  def as_json(options = {})
    {
        :name => name,
        :identifier_token => identifier_token,
        :created_at => created_at,
        :updated_at => updated_at
    }
  end
end
