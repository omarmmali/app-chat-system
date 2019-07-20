class CreateClientApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :client_applications do |t|
      t.string :name
      t.string :identifier_token
      t.timestamps
    end
  end
end