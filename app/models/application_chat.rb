class ApplicationChat < ApplicationRecord
  belongs_to :client_application
  before_create :generate_identifier_number

  def as_json(options = {})
    {
        :number => identifier_number
    }
  end

  def generate_identifier_number
    self.identifier_number = self.client_application.chats.count + 1
  end
end
