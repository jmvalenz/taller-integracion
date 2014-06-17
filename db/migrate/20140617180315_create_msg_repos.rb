class CreateMsgRepos < ActiveRecord::Migration
  def change
    create_table :msg_repos do |t|
      t.string :sku
      t.int :fecha
      t.string :almacenId
      t.string :int

      t.timestamps
    end
  end
end
