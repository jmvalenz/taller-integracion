class CreateReservation < ActiveRecord::Migration
  def change
    create_table :reservation do |t|
      t.integer   :customer_id
      t.string   :sku
      t.integer   :amount

      t.timestamps
    end
  end
end
