class AddLockingVersionToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_messages, :lock_version, :integer, default: 0
  end
end
