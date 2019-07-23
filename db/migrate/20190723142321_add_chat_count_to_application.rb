class AddChatCountToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :client_applications, :chat_count, :integer, default: 0
  end
end
