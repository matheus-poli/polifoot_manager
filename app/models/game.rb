class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :game_events, dependent: :destroy

  # Callbacks for Lobby
  after_create_commit { broadcast_prepend_to "games_lobby" }
  after_destroy_commit { broadcast_remove_to self }

  # Callbacks for Game Room
  after_update_commit :broadcast_game_start, if: -> { saved_change_to_status? && status == "em_andamento" }

  def player_number_for_user(user_token)
    return 1 if players.empty?
    
    existing_player = players.find_by(user_token: user_token)
    return existing_player.player_number if existing_player&.player_number
    
    # Determinar número baseado no user_token para consistência
    # Coleta todos os tokens existentes incluindo o novo
    all_user_tokens = (players.pluck(:user_token).compact + [user_token]).uniq.sort
    all_user_tokens.index(user_token) + 1
  end

  def default_player_name_for_number(player_number)
    "Jogador #{player_number}"
  end

  def default_team_name_for_number(player_number)
    case player_number
    when 1
      "Vermelho+Preto"
    when 2
      "Branco+Preto"
    else
      "Time #{player_number}"
    end
  end

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
