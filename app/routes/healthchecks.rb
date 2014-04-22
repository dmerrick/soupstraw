class Soupstraw < Sinatra::Base

  # return OK if deafguy is alive and
  # running the right configuration
  get '/healthcheck/deafguy' do
    content_type 'text/plain'
    response = home_api('/')
    return 'NODEAFGUY' unless response.body =~ /deafguy/
    'OK'
  end

  # return OK if the media center is alive and
  # running the right configuration
  get '/healthcheck/mediacenter' do
    content_type 'text/plain'
    response = home_api('/healthcheck/mediacenter')
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
