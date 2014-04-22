class Soupstraw < Sinatra::Base

  # return OK if all components are alive
  get '/healthcheck' do
    content_type 'text/plain'

    # start by checking cronhealth
    cronhealth_status = check_cron
    return cronhealth_status unless cronhealth_status =~ /OK/

    # check the media center, which also tests deafguy
    mediacenter_status = check_media_center
    return mediacenter_status unless mediacenter_status =~ /OK/

    # if the above worked, we're good
    'OK'
  end

  # check that deafguy is alive and working
  get '/healthcheck/deafguy' do
    content_type 'text/plain'
    check_deafguy
  end

  # check that the media center is alive and working
  get '/healthcheck/mediacenter' do
    content_type 'text/plain'
    check_media_center
  end

  # check that the snapshots are still recent
  get '/cronhealth' do
    content_type 'text/plain'
    check_cron
  end

end
