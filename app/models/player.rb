class Player < ApplicationRecord
  belongs_to :game

  # For the Game Room
  after_update_commit { broadcast_replace_to game }

  # For the Lobby
  after_create_commit { broadcast_update_lobby }
  after_destroy_commit { broadcast_update_lobby }

  # Delete game if no players left
  after_destroy :destroy_game_if_empty

  private

  def broadcast_update_lobby
    broadcast_replace_to(
      "games_lobby",
      target: self.game,
      partial: "games/game",
      locals: { game: self.game, current_player: nil }
    )
  end

  def destroy_game_if_empty
    # Use reload to get the current count from the database
    game.destroy if game.players.reload.empty?
  end
end
