class CreateProductOrders < ActiveRecord::Migration
  def change
    create_table :product_orders do |t|
      t.string  :sku
      t.integer :order_id
      t.decimal :amount
      t.string  :order_unit

      t.timestamps
    end
    add_index :product_orders, :order_id
  end
end
