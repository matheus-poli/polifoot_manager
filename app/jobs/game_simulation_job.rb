class GameSimulationJob < ApplicationJob
  queue_as :default

  def perform(game)
    GameSimulator.call(game)
  end
end
