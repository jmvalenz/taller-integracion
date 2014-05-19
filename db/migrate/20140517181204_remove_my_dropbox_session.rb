class RemoveMyDropboxSession < ActiveRecord::Migration
  def change
    remove_index :my_dropbox_sessions, :account_email
    remove_index :my_dropbox_sessions, :authorized
    
    drop_table :my_dropbox_sessions do |t|
      t.string :app_key
      t.string :app_secret
      t.string :account_email
      t.boolean :authorized, default: false
      t.text :serialized_session
 
      t.timestamps
    end
  end
end
