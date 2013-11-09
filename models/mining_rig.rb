class MiningRig < ActiveRecord::Base
  validates_presence_of :name
  has_many :bitcoin_stats_snapshots

  def nonzero_snapshots
    bitcoin_stats_snapshots.nonzero
  end

  def days_running
    Date.today - start_date.to_date
  end

  def take_snapshot!
    BitcoinStatsSnapshot.create do |s|
      s.mining_rig = self
      s.btc_mined  = s.current_btc_mined
      s.usd_value  = s.current_usd_value
    end
  end
end
