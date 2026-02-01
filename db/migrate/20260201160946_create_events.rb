class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.integer :capacity
      t.bigint :organizer_id, index: true
      t.timestamps
    end
  end
end
