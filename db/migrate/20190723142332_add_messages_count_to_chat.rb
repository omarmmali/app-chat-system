class AddMessagesCountToChat < ActiveRecord::Migration[5.2]
  def change
    add_column :application_chats, :message_count, :integer, default: 0
  end
end
