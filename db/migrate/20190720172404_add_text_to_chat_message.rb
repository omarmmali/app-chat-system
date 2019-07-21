class AddTextToChatMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_messages, :text, :string
  end
end
