module Bitcoin

  # hash to store the most recent USD value
  @last_usd_value ||= Hash.new(0)

  # find current BTC->USD exchange rate (weighted average)
  def current_usd_value
    # return cached value if it was taken recently
    cache_age = (Time.now - @last_usd_value[:last_update]).to_i
    return @last_usd_value[:value] if cache_age < 2.minutes

    # otherwise, get the current USD value from bitcoinaverage.com API
    usd_value_url = 'https://api.bitcoinaverage.com/ticker/global/USD'
    current_value_json = JSON.parse(URI.parse(usd_value_url).read)

    # cache the latest value and return it
    @last_usd_value[:last_update] = Time.now
    @last_usd_value[:value] = current_value_json['last'].to_f
  end

  def usd_format(value, commas: true)
    string = value.round(2).to_s
    string += '0' if string.split('.').last.size != 2
    string = commaize(string) if commas
    string = '$' + string
    # move the negative sign to the left of the dollar sign (if needed)
    string.sub('$-','-$')
  end

  # used for coloring rows in the blade health table
  def efficiency_to_color(efficiency)
    case efficiency.to_f
    when 0.0..90.0
      return 'danger'
    when 91.0..98.0
      return 'warning'
    when 99.0..100.0
      return '' # just be white
    else
      return 'success'
    end
  end

  # allow Bitcoin.foo() calls
  module_function :current_usd_value
  module_function :usd_format

end
