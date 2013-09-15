require 'awesome_print'

namespace :bitcoin do

  desc "Take a snapshot of the bitcoin stats"
  task :snapshot do
    snapshot = BitcoinStatsSnapshot.new do |s|
	  s.btc_mined = s.current_btc_mined
	  s.usd_value = s.current_usd_value
	end
	snapshot.save!
	ap snapshot
  end

end
