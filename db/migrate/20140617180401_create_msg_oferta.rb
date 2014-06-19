class CreateMsgOferta < ActiveRecord::Migration
  def change
    create_table :msg_oferta do |t|
      t.string :sku
      t.int :precio
      t.int :inicio
      t.int :fin

      t.timestamps
    end
  end
end
