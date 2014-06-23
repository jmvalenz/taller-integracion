class RenameMsgOfertasTable < ActiveRecord::Migration
  def change
    rename_table :msg_oferta, :sales
  end
end
