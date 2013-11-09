class AddMiningRigToSnapshots < ActiveRecord::Migration
  def up
  	change_table :bitcoin_stats_snapshots do |t|
	  t.belongs_to :mining_rig
	end
  end

  def down
  	 change_table :bitcoin_stats_snapshots do |t|
	  t.remove :mining_rig_id
	end
  end
end
