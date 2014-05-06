module SoupstrawHelpers

  def is_user?
    @user != nil
  end

  def is_dana?
    is_user? && @user.id == 1
  end

  def bootstrap_theme
    path = "/stylesheets/bootstrap/#{subdomain}.bootstrap.min.css"
    if File.exist? "#{settings.root}/public#{path}"
      return path
    else
      return nil
    end
  end

  def apple_touch_icon(icon)
    path = "/images/#{icon}-apple-touch-icon-144x144-precomposed.png"
    if File.exist? "#{settings.root}/public#{path}"
      return path
    else
      # default site icon
      return "/images/tablet-apple-touch-icon-144x144-precomposed.png"
    end
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  # add commas to a large number
  def commaize(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def home_api(path)
    uri = URI.parse('http://' + settings.app[:home_url] + path)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(settings.app[:home_username], settings.app[:home_password])
    #TODO: catch exceptions here
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(request)
  end

  # make a request to a path on the current server
  def get_self(path)
    uri = URI.parse("http://localhost:#{request.env["SERVER_PORT"] + path}")
    request = Net::HTTP::Get.new(uri.request_uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(request)
  end

  def subdomain
    uri = URI.parse("http://#{request.env["HTTP_HOST"]}")
    parts = uri.host.split(".")
    parts.pop(2)
    # use this if the tld size changes (i.e. foo.bar.soupstraw.com)
    #parts.pop(settings.tld_size + 1)
    parts.first
  end

  def wall_remote_settings
    @title = 'Soupstraw Wall Remote!'
    @no_navbar = true
    @refresh = "#{30.minutes}; url=/wall_remote"
  end

end