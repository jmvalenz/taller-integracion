class AddSaleToTws < ActiveRecord::Migration
  def change
    add_column :tws, :sale_id, :integer
    add_index :tws, :sale_id
  end
end
