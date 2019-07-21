class AddIndexToApplicationChats < ActiveRecord::Migration[5.2]
  def change
    add_index :application_chats, :identifier_number
  end
end
