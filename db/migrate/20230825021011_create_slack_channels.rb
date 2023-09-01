class CreateSlackChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :slack_channels do |t|
      t.string :channel_id, null: false
      t.string :name, null: false, unique: true

      t.timestamps
    end
    add_index :slack_channels, :channel_id, unique: true
    add_index :slack_channels, :name, unique: true
  end
end
