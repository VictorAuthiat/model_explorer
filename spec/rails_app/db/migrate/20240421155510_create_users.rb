class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password, null: false, default: ""
      t.timestamps
    end
  end
end
