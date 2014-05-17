class CreateReservation < ActiveRecord::Migration
  def change
    create_table :reservation do |t|
      t.integer   :sku
      t.integer   :customer_id
      t.integer   :amount

      t.timestamps
  end
end
