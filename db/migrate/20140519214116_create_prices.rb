class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :product_id
      t.decimal :price
      t.date :expiration_date
      t.date :update_date
      t.decimal :cost
      t.decimal :transfer_cost

      t.timestamps
    end
    
    add_index :prices, :product_id
    
  end
end
