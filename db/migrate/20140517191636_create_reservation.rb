class CreateReservation < ActiveRecord::Migration
  def change
    create_table :reservation do |t|
      t.string   :sku
      t.string   :customer_id
      t.integer   :amount

      t.timestamps
    end
  end
end
