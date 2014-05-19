class ChangeCustomerIdOnReservations < ActiveRecord::Migration
  def change
    change_column :reservations, :customer_id, :string
  end
end
