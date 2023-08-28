class CreateObservedMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :observed_members do |t|
      t.references :user, :channel_member, foreign_key: true, index: false, null: false

      t.timestamps
    end
    add_index :observed_members, %i[user_id channel_member_id], unique: true
  end
end
