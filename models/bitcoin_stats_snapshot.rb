class BitcoinStatsSnapshot < ActiveRecord::Base

  # dont save records that resulted in an error
  validates  :btc_mined, numericality: { greater_than: 0.0 }
  belongs_to :mining_rig

  def stats_url
    if mining_rig.pool_name == 'eligius'
      return 'http://eligius.st/~luke-jr/raw/7/balances.json'
    elsif mining_rig.pool_name == 'btcguild'
      return "https://www.btcguild.com/api.php?api_key=#{mining_rig.pool_api_key}"
    elsif mining_rig.pool_name == 'btcdig'
      return "http://btcdig.com/api/v1/user/stats/#{mining_rig.pool_api_key}"
    else
      raise 'unsupported mining pool'
    end
  end

  def btc_per_day
    return 0 if mining_rig.days_running <= 0
    (btc_mined / mining_rig.days_running).round(8)
  end

  #TODO: consider profit() and profit(:usd)
  def btc_profit
    break_even.abs
  end

  #TODO: consider profit_per_day() and profit_per_day(:usd)
  def btc_profit_per_day
    return 0 if mining_rig.days_running <= 0
    (btc_profit / mining_rig.days_running).round(8)
  end

  def usd_per_day
    return 0 if mining_rig.days_running <= 0
    (total_earned / mining_rig.days_running).round(2)
  end

  #TODO: consider profit() and profit(:usd)
  def usd_profit
    break_even(:usd).abs
  end

  #TODO: consider profit_per_day() and profit_per_day(:usd)
  def usd_profit_per_day
    return 0 if mining_rig.days_running <= 0
    (total_earned / mining_rig.days_running).round(2)
  end

  # find total BTC mined
  def current_btc_mined
    begin
      bitcoin_stats_json = JSON.parse(URI.parse(stats_url).read)
    rescue Timeout::Error, JSON::ParserError
      # return a balance of zero if something goes wrong
      return 0.0
    end

    # get the total from the Eligius mining pool
    if mining_rig.pool_name == 'eligius'
      # return zero if the wallet_address is not in the pool
      return 0.0 unless bitcoin_stats_json[mining_rig.wallet_address]

      # add the current balance and the total paid balance
      total  = bitcoin_stats_json[mining_rig.wallet_address]['balance'].to_i
      total += bitcoin_stats_json[mining_rig.wallet_address]['everpaid'].to_i

      # convert to a float
      total *= 0.00000001

    # get the total from the BTC Guild mining pool
    elsif mining_rig.pool_name == 'btcguild'
      # return zero if the api key is invalid
      return 0.0 unless bitcoin_stats_json['user']['total_rewards']

      total = bitcoin_stats_json['user']['total_rewards']

    # get the total from the BTCDig mining pool
    elsif mining_rig.pool_name == 'btcdig'
      # return zero if the api key is invalid
      return 0.0 unless bitcoin_stats_json['total_reward']

      total = bitcoin_stats_json['total_reward']

    # fail if the pool is not supported
    else
      raise 'unsupported mining pool'
    end

    # add the preexisting_btc_balance if required
    total += mining_rig.preexisting_btc_balance if mining_rig.preexisting_btc_balance
    total.round(8)
  end

  # returns the remaining amount to earn in order to break even
  def break_even(in_usd = false)
    if in_usd
      return 0.0 if mining_rig.usd_cost.to_f == 0.0
      return (mining_rig.usd_cost - total_earned).round(2)
    else
      return 0.0 if mining_rig.btc_cost.to_f == 0.0
      return (mining_rig.btc_cost - btc_mined).round(8)
    end
  end

  # returns break even progress as a percentage
  def break_even_progress(in_usd = false)
    if in_usd
      return 0 if mining_rig.usd_cost == 0
      return ((total_earned / mining_rig.usd_cost) * 100.0).round(2)
    else
      return 0 if mining_rig.btc_cost == 0
      return ((btc_mined / mining_rig.btc_cost) * 100.0).round(2)
    end
  end

  def break_even_bar_value(in_usd = false)
    if break_even_progress(in_usd) > 100
      percent = (100 / break_even_progress(in_usd)) * 100
      return percent.round(2)
    end
    break_even_progress(in_usd)
  end

  def days_to_break_even(in_usd = false)
    break_even(in_usd) / (in_usd ? usd_per_day : btc_per_day)
  end

  def total_earned
    usd_value * btc_mined
  end

  # this allows you to combine two snapshots together
  def +(other_snapshot)
    BitcoinStatsSnapshot.new do |snap|
      snap.btc_mined  = btc_mined + other_snapshot.btc_mined
      # take the average of their usd_values
      snap.usd_value  = (usd_value + other_snapshot.usd_value) / 2
      snap.mining_rig = mining_rig + other_snapshot.mining_rig
    end
  end

end
