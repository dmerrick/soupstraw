module Bitcoin

  # find current BTC->USD exchange rate (weighted average)
  def current_usd_value
    #FIXME: this doesn't work cause you can't access settings
    # within a static method (for whatever reason)
    #usd_value_url = settings.app[:usd_value_api]
    usd_value_url = 'http://api.bitcoinaverage.com/no-mtgox/ticker/USD'
    current_value_json = JSON.parse(URI.parse(usd_value_url).read)
    current_value_json['last'].to_f
  end

  def usd_format(value)
    string = value.round(2).to_s
    string += '0' if string.split('.').last.size != 2
    '$' + string
  end

  # used for coloring rows in the blade health table
  def efficiency_to_color(efficiency)
    case efficiency.to_f
    when 0..90
      return 'danger'
    when 91..98
      return 'warning'
    when 99..100
      return ''
    else
      return 'success'
    end
  end

  # allow Bitcoin.foo() calls
  module_function :current_usd_value
  module_function :usd_format

end
