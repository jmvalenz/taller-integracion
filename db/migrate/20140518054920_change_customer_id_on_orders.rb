class ChangeCustomerIdOnOrders < ActiveRecord::Migration
  def change
    change_column :orders, :customer_id, :string
  end
end
