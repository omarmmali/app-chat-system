class CreateChatMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_messages do |t|
      t.belongs_to :application_chat
      t.integer :identifier_number
      t.timestamps
    end
  end
end
