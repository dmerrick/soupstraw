class MiningRig < ActiveRecord::Base

  #TODO: more validations here
  validates_presence_of :name
  validates_presence_of :pool_name
  has_many :bitcoin_stats_snapshots

  # supported periods for the graph interval
  # (default is :auto)
  GRAPH_INTERVALS = { auto: 0, hour: 1, day: 2, week: 3 }

  # find all active miners
  scope :active, -> { where( active: true ) }

  def snapshots
    bitcoin_stats_snapshots
  end

  def last_snapshot
    bitcoin_stats_snapshots.last
  end

  def days_running
    DateTime.now - start_date.to_datetime
  end

  def total_earned
    last_snapshot.total_earned
  end

  def take_snapshot!
    BitcoinStatsSnapshot.create do |s|
      s.mining_rig = self
      s.btc_mined  = s.current_btc_mined
      s.usd_value  = Bitcoin.current_usd_value
    end
  end

  # override the getter so we can use symbols
  # i.e. rig.graph_interval #=> :auto
  def graph_interval
    GRAPH_INTERVALS.key(read_attribute(:graph_interval))
  end

  # override the setter so we can use symbols
  # i.e. rig.graph_interval = :hour
  def graph_interval=(interval)
    write_attribute(:graph_interval, GRAPH_INTERVALS[interval])
  end

  # return different graph data based on the graph_interval
  def average_earned_graph_data(interval = nil)
    # use the default graph interval if none specified
    interval ||= effective_graph_interval
    # run the corresponding method
    send("average_earned_by_#{interval}")
  end

  # returns the graph interval, replacing :auto as necessary
  def effective_graph_interval
    # automatically change the timescale based on days_running
    if graph_interval == :auto
      case days_running.floor
      when 0..5
        return :hour
      when 6..90
        return :day
      else
        return :week
      end
    else
      # otherwise use whatever interval was specified
      return graph_interval
    end
  end

  # format the data for chartkick
  def average_earned_by_hour
    snapshots.group_by_hour(:created_at).average('btc_mined * usd_value')
  end

  # format the data for chartkick
  def average_earned_by_day
    snapshots.group_by_day(:created_at).average('btc_mined * usd_value')
  end

  # format the data for chartkick
  def average_earned_by_week
    snapshots.group_by_week(:created_at).average('btc_mined * usd_value')
  end

  # this allows you to combine two rigs together
  def +(other_rig)
    MiningRig.new do |rig|
      rig.name = "Composite of MiningRig##{id} and MiningRig##{other_rig.id}"
      rig.btc_cost = btc_cost + other_rig.btc_cost
      rig.usd_cost = usd_cost + other_rig.usd_cost

      # use the first rig's settings:
      #FIXME: use something else here?
      rig.start_date     = start_date
      rig.graph_interval = graph_interval
    end
  end
end
