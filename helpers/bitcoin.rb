module Bitcoin

  def self.usd_value_url
    'http://api.bitcoinaverage.com/no-mtgox/ticker/USD'
  end

  # find current BTC->USD exchange rate (weighted average)
  def self.current_usd_value
    current_value_json = JSON.parse(URI.parse(usd_value_url).read)
    current_value_json["last"].to_f
  end

end
