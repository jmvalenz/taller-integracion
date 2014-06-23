class AddProductIdToMsgOfertas < ActiveRecord::Migration
  def change
    add_column :msg_oferta, :product_id, :integer
    add_index :msg_oferta, :product_id
  end
end
