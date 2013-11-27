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

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def home_api(path)
    uri = URI.parse('http://' + settings.app[:home_url] + path)
    request = Net::HTTP::Get.new(uri.request_uri)
    #request.basic_auth(settings.app[:home_username], settings.app[:home_password])
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
end