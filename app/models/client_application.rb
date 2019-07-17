require 'securerandom'

class ClientApplication < ApplicationRecord
  before_create :create_identifier_token

  def create_identifier_token
    self.identifier_token=SecureRandom.urlsafe_base64(10)
  end
end
