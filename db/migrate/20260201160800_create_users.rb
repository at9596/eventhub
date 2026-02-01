class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, index: { unique: true }
      t.string :password_digest
      t.integer :role
      t.string :name

      t.timestamps
    end
  end
end
