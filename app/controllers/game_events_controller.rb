class GameEventsController < ApplicationController
  before_action :set_game_event, only: %i[ show edit update destroy ]

  # GET /game_events
  def index
    @game_events = GameEvent.all
  end

  # GET /game_events/1
  def show
  end

  # GET /game_events/new
  def new
    @game_event = GameEvent.new
  end

  # GET /game_events/1/edit
  def edit
  end

  # POST /game_events
  def create
    @game_event = GameEvent.new(game_event_params)

    if @game_event.save
      redirect_to @game_event, notice: "Game event was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /game_events/1
  def update
    if @game_event.update(game_event_params)
      redirect_to @game_event, notice: "Game event was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /game_events/1
  def destroy
    @game_event.destroy!
    redirect_to game_events_path, notice: "Game event was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_event
      @game_event = GameEvent.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def game_event_params
      params.expect(game_event: [ :minute, :description, :game_id ])
    end
end
