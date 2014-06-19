class CreateMsgOferta < ActiveRecord::Migration
  def change
    create_table :msg_oferta do |t|
      t.string :sku
      t.integer :precio
      t.integer :inicio
      t.integer :fin

      t.timestamps
    end
  end
end
