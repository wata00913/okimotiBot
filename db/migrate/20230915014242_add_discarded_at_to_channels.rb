class AddDiscardedAtToChannels < ActiveRecord::Migration[7.0]
  def change
    add_column :slack_channels, :discarded_at, :datetime
    add_index :slack_channels, :discarded_at
  end
end
