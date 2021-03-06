class Fetcher < ActiveRecord::Base
  include StiBecome
  include Platformable

  belongs_to :item_code
  belongs_to :genre
  belongs_to :segment

  TYPES = %w(ItemFetcher RankingFetcher)
  validates :type, inclusion: TYPES
end
