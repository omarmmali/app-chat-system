class ApplicationChat < ApplicationRecord
  alias_attribute :messages, :chat_messages

  belongs_to :client_application
  has_many :chat_messages

  def as_json(options = {})
    {
        application_token: self.client_application.identifier_token,
        number: identifier_number,
        lock_version: lock_version
    }
  end
end
