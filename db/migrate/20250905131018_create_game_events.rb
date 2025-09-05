class CreateGameEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :game_events do |t|
      t.integer :minute
      t.text :description
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
