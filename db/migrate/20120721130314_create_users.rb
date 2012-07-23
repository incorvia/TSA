class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.string :password_digest

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :password_digest
  end
end
