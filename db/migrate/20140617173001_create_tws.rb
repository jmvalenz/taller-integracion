class CreateTws < ActiveRecord::Migration
  def change
    create_table :tws do |t|

      t.timestamps
    end
  end
end
