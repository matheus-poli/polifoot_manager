class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_user_token

  helper_method :current_player

  private

  def set_user_token
    session[:user_token] ||= SecureRandom.hex(16)
  end

  def current_player
    @current_player ||= Player.find_by(id: session[:player_id], user_token: session[:user_token])
  end
end
