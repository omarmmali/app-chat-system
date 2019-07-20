class CreateApplicationChats < ActiveRecord::Migration[5.2]
  def change
    create_table :application_chats do |t|
      t.belongs_to :client_application
      t.integer :identifier_number
      t.timestamps
    end
  end
end
