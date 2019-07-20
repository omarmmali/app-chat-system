class ApplicationChat < ApplicationRecord
  alias_attribute :messages, :chat_messages

  belongs_to :client_application
  has_many :chat_messages

  before_create :generate_identifier_number


  def as_json(options = {})
    {
        :number => identifier_number
    }
  end

  private

  def generate_identifier_number
    self.identifier_number = self.client_application.chats.count + 1
  end
end
