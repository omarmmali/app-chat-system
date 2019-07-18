require 'securerandom'

class ClientApplication < ApplicationRecord
  before_create :create_identifier_token

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
