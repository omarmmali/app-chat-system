class AddIndexToChatMessages < ActiveRecord::Migration[5.2]
  def change
    add_index :chat_messages, :identifier_number
  end
end
