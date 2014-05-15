class CreateCrms < ActiveRecord::Migration
  def change
    create_table :crms do |t|

      t.timestamps
    end
  end
end
