class GameEvent < ApplicationRecord
  belongs_to :game

  after_create_commit { broadcast_append_to self.game }
end
