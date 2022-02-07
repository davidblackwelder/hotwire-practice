class ActivityController < ApplicationController
  before_action :require_signin

  def index
    @fish_catches = FishCatch.activity

    @fish_catches = current_user.assign_my_likes_to_catches(@fish_catches)
  end
end
