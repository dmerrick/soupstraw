module Healthchecks

  # return OK if deafguy is alive and
  # running the right configuration
  def check_deafguy
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
  def check_media_center
    begin
      response = home_api('/healthcheck/mediacenter')
    rescue Errno::ECONNREFUSED
      return 'DEAFGUYDOWN'
    end
    return response.body unless response.body =~ /OK/
    'OK'
  end

  # return OK if snapshots are still recent
  def check_cron(threshold = 10.minutes)
    last_snapshot = BitcoinStatsSnapshot.last
    seconds_since_last_snapshot = DateTime.now.to_i - last_snapshot.created_at.to_i
    return 'NOCRON' if seconds_since_last_snapshot > threshold
    'OK'
  end

end
