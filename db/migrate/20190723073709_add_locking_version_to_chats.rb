class AddLockingVersionToChats < ActiveRecord::Migration[5.2]
  def change
    add_column :application_chats, :lock_version, :integer, default: 0
  end
end
