class Item < ActiveRecord::Base
  include TimeScopes

  belongs_to :item_code
  belongs_to :ranking

  validates :item_code_id, presence: true

  delegate :genre, :genre_id, to: :ranking, allow_nil: true
  delegate :segment, :segment_id, to: :ranking, allow_nil: true

  def download_count
    download_count_min && download_count_max &&
      [download_count_min, download_count_max]
  end

  def download_count= arg
    if arg.blank?
      self.download_count_min = nil
      self.download_count_max = nil
    elsif arg.respond_to? :minmax
      self.download_count_min, self.download_count_max = arg.minmax
    else
      fail ArgumentError, 'argument does not respond to minmax'
    end
  end

  def download_count_min
    super.to_i
  end

  def download_count_max
    super.to_i
  end

  def last_item
    @last_item ||=
      ranking && ranking.last_ranking &&
      ranking.last_ranking.items.find_by(item_code_id: item_code_id)
  end

  def last_rank
    last_item.try :rank
  end
end
