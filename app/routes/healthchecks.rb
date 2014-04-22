class Soupstraw < Sinatra::Base

  # return OK if all components are alive
  get '/healthcheck' do
    content_type 'text/plain'

    # start by checking cronhealth
    cronhealth_status = get_self('/cronhealth').body
    return cronhealth_status unless cronhealth_status =~ /OK/

    # check the media center, which also tests deafguy
    mediacenter_status = get_self('/healthcheck/mediacenter').body
    return mediacenter_status unless mediacenter_status =~ /OK/

    # if the above worked, we're good
    'OK'
  end

  # return OK if deafguy is alive and
  # running the right configuration
  get '/healthcheck/deafguy' do
    content_type 'text/plain'
    begin
      response = home_api('/')
    rescue Errno::ECONNREFUSED
      return 'DEAFGUYDOWN'
    end
    return 'NOTDEAFGUY' unless response.body =~ /deafguy/
    'OK'
  end

  # return OK if the media center is alive and
  # running the right configuration
  get '/healthcheck/mediacenter' do
    content_type 'text/plain'
    begin
      response = home_api('/healthcheck/mediacenter')
    rescue Errno::ECONNREFUSED
      return 'DEAFGUYDOWN'
    end
    return response.body unless response.body =~ /OK/
    'OK'
  end

  # return OK if snapshots are still recent
  get '/cronhealth' do
    content_type 'text/plain'
    threshold = 10.minutes
    last_snapshot = BitcoinStatsSnapshot.last
    seconds_since_last_snapshot = DateTime.now.to_i - last_snapshot.created_at.to_i
    return 'NOCRON' if seconds_since_last_snapshot > threshold
    'OK'
  end

end
