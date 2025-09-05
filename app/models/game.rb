class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :game_events, dependent: :destroy

  # Callbacks for Lobby
  after_create_commit { broadcast_prepend_to "games_lobby" }
  after_destroy_commit { broadcast_remove_to self }

  # Callbacks for Game Room
  after_update_commit :broadcast_game_start, if: -> { saved_change_to_status? && status == "em_andamento" }

  private

  def broadcast_game_start
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self, :content),
      partial: "games/content",
      locals: { game: self }
    )
  end
end
