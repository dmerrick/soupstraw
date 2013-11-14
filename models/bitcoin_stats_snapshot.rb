class BitcoinStatsSnapshot < ActiveRecord::Base

  # dont save records that resulted in an error
  validates  :btc_mined, numericality: { greater_than: 0.0 }
  belongs_to :mining_rig

  # right now we only support Eligius
  def stats_url
    'http://eligius.st/~luke-jr/raw/7/balances.json'
  end

  def btc_per_day
    return 0 if mining_rig.days_running <= 0
    (btc_mined / mining_rig.days_running).round(8)
  end

  def usd_per_day
    return 0 if mining_rig.days_running <= 0
    (total_earned.to_f / mining_rig.days_running).round(2)
  end

  # find total BTC mined
  def current_btc_mined
    begin
      bitcoin_stats_json = JSON.parse(URI.parse(stats_url).read)
    rescue Timeout::Error
      #flash.now[:danger] = "Connection to mining stats page timed out. Is their server down?"
      return 0.0
    end

    # return zero if the wallet_address is not in the pool
    return 0.0 unless bitcoin_stats_json[mining_rig.wallet_address]

    total  = bitcoin_stats_json[mining_rig.wallet_address]['balance'].to_i
    total *= 0.00000001
    total += mining_rig.preexisting_btc_balance if mining_rig.preexisting_btc_balance
    total.round(8)
  end

  def break_even(in_usd = false)
    return (mining_rig.usd_cost - total_earned.to_f).round(2) if in_usd
    return (mining_rig.btc_cost - btc_mined).round(8)
  end

  def break_even_progress(in_usd = false)
    return ((total_earned.to_f / mining_rig.usd_cost) * 100.0).round(2) if in_usd
    return ((btc_mined / mining_rig.btc_cost) * 100.0).round(2)
  end

  #TODO: make this return a number instead of a string
  def total_earned
    total = (usd_value * btc_mined).round(2).to_s
    total += '0' if total.to_s.split('.').last.size != 2
    total
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
