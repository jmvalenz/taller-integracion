class CreatePricings < ActiveRecord::Migration
  def change
    create_table :pricings do |t|
      t.integer :sku
      t.integer :precio
      t.date :fecha_actualizacion
      t.date :fecha_vigencia
      t.integer :costo_producto
      t.integer :cargo_traspaso

      t.timestamps
    end
  end
end
