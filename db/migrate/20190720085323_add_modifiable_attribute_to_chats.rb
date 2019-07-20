class AddModifiableAttributeToChats < ActiveRecord::Migration[5.2]
  def change
    add_column :application_chats, :modifiable_attribute, :string
  end
end
