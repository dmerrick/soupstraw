module Bitcoin

  def usd_value_url
    'http://api.bitcoinaverage.com/no-mtgox/ticker/USD'
  end

  # find current BTC->USD exchange rate (weighted average)
  def current_usd_value
    current_value_json = JSON.parse(URI.parse(usd_value_url).read)
    current_value_json['last'].to_f
  end

  def usd_format(value)
    string = value.round(2).to_s
    string += '0' if string.split('.').last.size != 2
    '$' + string
  end

  # allow Bitcoin.foo() calls
  module_function :usd_value_url
  module_function :current_usd_value
  module_function :usd_format

end
