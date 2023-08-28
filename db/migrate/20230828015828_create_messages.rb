class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :channel_member, foreign_key: true, null: false
      t.decimal :slack_timestamp, precision: 16, scale: 6, null: false
      t.text :original_message, null: false

      t.timestamps
    end
  end
end
