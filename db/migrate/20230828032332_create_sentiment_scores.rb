class CreateSentimentScores < ActiveRecord::Migration[7.0]
  def change
    create_table :sentiment_scores do |t|
      t.references :message, foreign_key: true, null: false
      t.float :positive, null: false
      t.float :negative, null: false
      t.float :neutral, null: false
      t.float :mixed, null: false

      t.timestamps
    end
  end
end
