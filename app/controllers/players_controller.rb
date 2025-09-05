class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]

  # GET /players
  def index
    @players = Player.all
  end

  # GET /players/1
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to @player, notice: "Player was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /players/1
  def update
    if @player.update(player_params.merge(ready: true))
      game = @player.game
      # Check if the other player is also ready
      other_player_ready = game.players.where.not(id: @player.id).first&.ready?
      if other_player_ready && game.status != "em_andamento"
        game.update(status: "em_andamento")
        GameSimulationJob.perform_later(game)
      end
      # The broadcast happens in the model, so the redirect is enough.
      redirect_to game_path(game), notice: "Você está pronto! Aguardando oponente..."
    else
      # This path should ideally not be reached with the new UI
      redirect_to game_path(@player.game), alert: "Não foi possível salvar suas escolhas."
    end
  end

  # DELETE /players/1
  def destroy
    @player.destroy!
    session.delete(:player_id)
    redirect_to games_path, notice: "Você saiu da partida.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def player_params
      params.require(:player).permit(:tactic)
    end
end