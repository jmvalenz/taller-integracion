class CreateWarehouseUsers < ActiveRecord::Migration
  def change
    create_table :warehouse_users do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
    add_index :warehouse_users, :username
  end
end
