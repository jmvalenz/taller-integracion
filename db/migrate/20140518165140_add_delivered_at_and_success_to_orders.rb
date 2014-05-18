class AddDeliveredAtAndSuccessToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivered_at, :datetime
    add_column :orders, :success, :boolean
  end
end
