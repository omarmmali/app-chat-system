class ChatMessage < ApplicationRecord
  belongs_to :application_chat

  before_create :generate_identifier_number

  def as_json(options = {})
    {
        :number => identifier_number
    }
  end

  private

  def generate_identifier_number
    self.identifier_number = self.application_chat.messages.count + 1
  end
end
