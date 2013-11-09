class MiningRig < ActiveRecord::Base
  validates_presence_of :name
  has_many :bitcoin_stats_snapshots

  def nonzero_snapshots
  	bitcoin_stats_snapshots.nonzero
  end
end
