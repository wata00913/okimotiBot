class AddDiscardedAtToChannelMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :channel_members, :discarded_at, :datetime
    add_index :channel_members, :discarded_at
  end
end
