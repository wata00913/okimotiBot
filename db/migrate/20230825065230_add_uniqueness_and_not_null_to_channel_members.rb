class AddUniquenessAndNotNullToChannelMembers < ActiveRecord::Migration[7.0]
  def change
    change_table(:channel_members) do |t|
      t.remove_references :slack_channel, :slack_account, foreign_key: true
      t.references :slack_channel, :slack_account, foreign_key: true, index: false, null: false
    end
    add_index :channel_members, %i[slack_channel_id slack_account_id], unique: true
  end
end
