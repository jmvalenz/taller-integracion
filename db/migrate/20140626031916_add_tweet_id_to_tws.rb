class AddTweetIdToTws < ActiveRecord::Migration
  def change
    add_column :tws, :tweet_id, :string
  end
end
