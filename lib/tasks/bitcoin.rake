require 'awesome_print'
require 'dogapi'

namespace :bitcoin do

  desc "Take a snapshot of the bitcoin stats"
  task :snapshot do
    rig_id = ENV['RIG_ID'] || 1
    rig = MiningRig.find(rig_id)
    snapshot = rig.take_snapshot!
    ap snapshot
  end

  namespace :snapshot do
    desc "Take snapshots for every mining rig"
    task :all do

      # send datadog events if we're in production
      if settings.environment == :production
        config_file = File.join(settings.root, 'config', 'application.yml')
        datadog_key = YAML::load(config_file)['development']['datadog_key']
        dog = Dogapi::Client.new(datadog_key)
      end

      MiningRig.active.each do |rig|
        if dog

          # send datadog an event if we're configured for it
          begin
            # take the snapshot
            snapshot = rig.take_snapshot!
            #TODO: add this
            #dog.emit_point('bitcoin.usd_value', snapshot.usd_value, host: hostname)
          rescue => e

            # send the exception and the snapshot
            #TODO: improve me
            content = e.inspect + '\n' + snapshot.inspect

            # create the event to send
            event = Dogapi::Event.new(content,
              msg_title:       'Cron job failed!',
              aggregation_key: 'cron_btc_snapshot',
              alert_type:      'error',
              tags:            ['ruby', 'dogapi', 'cron', 'bitcoin', settings.environment]
            )

            # shell out to get the hostname
            hostname = %[hostname]

            # actually send the event to datadog
            dog.emit_event(event, host: hostname)
          end

        else
          # otherwise just take the snapshot
          snapshot = rig.take_snapshot!
        end

        # finally, just print the snapshot
        ap snapshot
      end
    end
  end

end
