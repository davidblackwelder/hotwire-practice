class LikesController < ApplicationController
  before_action :require_signin
  before_action :find_fish_catch

  def create
    unless already_liked?
      like = @fish_catch.likes.create!(user: current_user)

      respond_to do |format|
        format.html { redirect_to activity_url }
      end
    end
  end

  def destroy
    if already_liked?
      like = current_user.likes.find(params[:id])
      like.destroy!

      respond_to do |format|
        format.html { redirect_to activity_url }
      end
    end
  end

private

  def find_fish_catch
    @fish_catch = FishCatch.find(params[:fish_catch_id])
  end

  def already_liked?
    current_user.likes.exists?(fish_catch_id: @fish_catch.id)
  end
end
