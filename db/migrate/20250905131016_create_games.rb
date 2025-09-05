class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :status
      t.integer :score_team_a
      t.integer :score_team_b

      t.timestamps
    end
  end
end
