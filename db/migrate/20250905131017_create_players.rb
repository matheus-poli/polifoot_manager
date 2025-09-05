class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name
      t.string :team_name
      t.string :tactic
      t.boolean :ready
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
