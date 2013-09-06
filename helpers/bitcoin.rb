module Bitcoin

  # configuration options
  ADDRESS = "1JT86GVai2r7sixvsJfJxNWHon9Dep2erh"
  COST_OF_MINER = 0.4416
  CURRENT_VALUE_URL = 'http://api.bitcoinaverage.com/no-mtgox/ticker/USD'
  BITCOIN_STATS_URL = "http://eligius.st/~luke-jr/raw/7/balances.json"

  # find current BTC->USD exchange rate (weighted average)
  def current_value
    return session[:current_value] if session[:current_value]
    current_value_json = JSON.parse(URI.parse(Bitcoin::CURRENT_VALUE_URL).read)
    session[:current_value] = current_value_json["last"].to_f
  end

  # find total BTC mined
  def total_mined
    return session[:total_mined] if session[:total_mined]
    bitcoin_stats_json = JSON.parse(URI.parse(Bitcoin::BITCOIN_STATS_URL).read)
    total = bitcoin_stats_json[Bitcoin::ADDRESS]["balance"].to_i * 0.00000001
    session[:total_mined] = total.round(8)
  end

  def break_even
    (Bitcoin::COST_OF_MINER - total_mined).round(8)
  end

  def break_even_progress
    ((total_mined / Bitcoin::COST_OF_MINER) * 100.0).round(2)
  end

  def total_earned
    total = (current_value * total_mined).round(2).to_s
    total += "0" if total_earned.to_s.split('.').last.size != 2
    total
  end
end
