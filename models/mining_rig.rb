class MiningRig < ActiveRecord::Base

  validates_presence_of :name
  has_many :bitcoin_stats_snapshots

  def nonzero_snapshots
    bitcoin_stats_snapshots.nonzero
  end

  def last_snapshot
    nonzero_snapshots.last
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

  # format the data for chartkick
  def average_earned_by_day
    nonzero_snapshots.group_by_day(:created_at).average('btc_mined * usd_value')
  end

  # format the data for chartkick
  def average_earned_by_week
    nonzero_snapshots.group_by_week(:created_at).average('btc_mined * usd_value')
  end

  # this allows you to combine two rigs together
  def +(other_rig)
    MiningRig.new do |rig|
      rig.name = "Composite of MiningRig##{id} and MiningRig##{other_rig.id}"
      rig.btc_cost = btc_cost + other_rig.btc_cost
      rig.usd_cost = usd_cost + other_rig.usd_cost

      #FIXME: use something else here?
      rig.start_date = start_date
    end
  end
end
