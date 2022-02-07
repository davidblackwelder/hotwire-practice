class User < ApplicationRecord
  has_secure_password

  has_many :tackle_box_items, dependent: :destroy
  has_many :fish_catches, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :username, presence: true,
            uniqueness: { case_sensitive: false }

  def search_catches(params={})
    sort_column =
      params[:sort]
        .presence_in(%w{ baits.name species weight length }) || "created_at"

    sort_direction =
      params[:direction].presence_in(%w{ asc desc }) || "asc"

    self.fish_catches
      .includes(:bait)
      .with_bait_name(params[:bait])
      .with_species(params[:species])
      .with_weight_between(params[:low_weight], params[:high_weight])
      .order(sort_column => sort_direction)
  end

  def tackle_box_item_for_most_recent_catch
    return nil if self.tackle_box_items.empty?

    if most_recent_catch = self.fish_catches.order(created_at: :desc).first
      item = self.tackle_box_items.find_by(bait_id: most_recent_catch.bait_id)
      item || self.tackle_box_items.first
    else
      self.tackle_box_items.first
    end
  end

  def assign_my_tackle_box_items_to_baits(baits)
    my_items = self.tackle_box_items.where(bait: baits)
    baits.map do |bait|
      bait.my_tackle_box_item =
        my_items.find { |i| i.bait_id == bait.id }
      bait
    end
  end

  def assign_my_likes_to_catches(fish_catches)
    my_likes = self.likes.where(fish_catch: fish_catches)
    fish_catches.map do |fish_catch|
      fish_catch.my_like =
        my_likes.find { |l| l.fish_catch_id == fish_catch.id }
      fish_catch
    end
  end
end
