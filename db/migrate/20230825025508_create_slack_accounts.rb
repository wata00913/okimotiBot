class CreateSlackAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :slack_accounts do |t|
      t.string :account_id, null: false
      t.string :name, null: false
      t.text :image_url

      t.timestamps
    end
    add_index :slack_accounts, :account_id, unique: true
  end
end
