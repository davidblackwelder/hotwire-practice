class FishCatchesController < ApplicationController
  before_action :require_signin
  before_action :set_fish_catch, only: %i[show edit update destroy]

  def index
    @pagy, @fish_catches =
      pagy(current_user.search_catches(params), items: params[:per_page] || 5)

    @max_weight = (current_user.fish_catches.maximum(:weight) || 10).round
    @bait_names = Bait.pluck(:name)
  end

  def show
  end

  def create
    @fish_catch = current_user.fish_catches.new(fish_catch_params)

    respond_to do |format|
      if @fish_catch.save
        format.html do
          redirect_to tackle_box_item_for_bait(@fish_catch.bait)
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @fish_catch.update(fish_catch_params)
        format.html { redirect_to tackle_box_item_for_bait(@fish_catch.bait) }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fish_catch.destroy

    respond_to do |format|
      format.html { redirect_to tackle_box_item_for_bait(@fish_catch.bait) }
    end
  end

private

  def set_fish_catch
    @fish_catch = current_user.fish_catches.find(params[:id])
  end

  def fish_catch_params
    params.require(:fish_catch).permit(:species, :weight, :length, :bait_id)
  end

  def tackle_box_item_for_bait(bait)
    current_user.tackle_box_items.where(bait_id: bait.id).first
  end

end
