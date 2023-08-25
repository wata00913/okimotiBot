class CreateChannelMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_members do |t|
      t.references(:slack_channel, :slack_account, foreign_key: true)

      t.timestamps
    end
  end
end
