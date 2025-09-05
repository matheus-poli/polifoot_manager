class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update join ]

  # GET /games
  def index
    @games = Game.includes(:players).order(created_at: :desc)
  end

  # GET /games/1
  def show
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  def create
    @game = Game.new(status: "aguardando", score_team_a: 0, score_team_b: 0)

    if @game.save
      player_number = @game.player_number_for_user(session[:user_token])
      player = @game.players.create(
        name: @game.default_player_name_for_number(player_number),
        team_name: @game.default_team_name_for_number(player_number),
        tactic: "Balanceado",
        ready: false,
        user_token: session[:user_token],
        player_number: player_number
      )
      session[:player_id] = player.id
      redirect_to @game, notice: "Partida criada com sucesso. Aguardando oponente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /games/1/join
  def join
    # Check if this user (user_token) already has a player in this game
    existing_player = @game.players.find_by(user_token: session[:user_token])

    if existing_player
      session[:player_id] = existing_player.id
      redirect_to @game, notice: "Você já está nesta partida!"
    elsif @game.players.count < 2
      player_number = @game.player_number_for_user(session[:user_token])
      player = @game.players.create(
        name: @game.default_player_name_for_number(player_number),
        team_name: @game.default_team_name_for_number(player_number),
        tactic: "Balanceado",
        ready: false,
        user_token: session[:user_token],
        player_number: player_number
      )
      session[:player_id] = player.id
      @game.update(status: "sala_cheia") if @game.players.count == 2
      redirect_to @game, notice: "Você entrou na partida!"
    else
      redirect_to games_path, alert: "Não foi possível entrar na partida. Sala cheia."
    end
  end

  # PATCH/PUT /games/1
  def update
    if @game.update(game_params)
      redirect_to @game, notice: "Game was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params.fetch(:game, {})
    end
end
