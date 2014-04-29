class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :sku
      t.integer :brand_id
      t.string :name
      t.decimal :price
      t.text :description
      t.string :image_path

      t.timestamps
    end
  end
end
