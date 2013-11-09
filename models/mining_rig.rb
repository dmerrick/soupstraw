class MiningRig < ActiveRecord::Base
  validates_presence_of :name
  has_many :bitcoin_stats_snapshots
end
