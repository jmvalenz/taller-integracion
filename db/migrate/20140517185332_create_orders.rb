class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer   :order_id
      t.integer   :customer_id
      t.integer   :address_id
      t.datetime  :entered_at
      t.date      :date_delivery

      t.timestamps
    end
    add_index :orders, :order_id
  end
end
