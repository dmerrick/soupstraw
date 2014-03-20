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
      env = settings.environment.to_s
      if env == 'production'
        config_file = File.join(settings.root, 'config', 'application.yml')
        datadog_key = YAML.load_file(config_file)[env]['datadog_key']
        dog = Dogapi::Client.new(datadog_key)
      end

      MiningRig.active.each do |rig|

        # send datadog an event if we're in production
        if dog
          begin
            # take the snapshot
            snapshot = rig.take_snapshot!
            #TODO: add this
            #dog.emit_point('bitcoin.usd_value', snapshot.usd_value, host: hostname)
          rescue => e

            # send the exception and the snapshot
            #TODO: improve me
            content = "#{e.inspect}
                       #{snapshot.inspect}"

            # create the event to send
            event = Dogapi::Event.new(content,
              msg_title:       'Cron job failed!',
              aggregation_key: 'cron_btc_snapshot',
              alert_type:      'error',
              tags:            ['ruby', 'dogapi', 'cron', 'bitcoin', env]
            )

            # actually send the event to datadog
            dog.emit_event(event, host: Dogapi.find_localhost)
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
