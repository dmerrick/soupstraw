require 'awesome_print'

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
      MiningRig.all.each do |rig|
        snapshot = rig.take_snapshot!
        ap snapshot
      end
    end
  end

end
