class DestroyCrm < ActiveRecord::Migration
  def change
    drop_table :crms do |t|

      t.timestamps
    end
  end
end
