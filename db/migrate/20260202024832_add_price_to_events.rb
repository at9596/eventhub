class AddPriceToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :price, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
