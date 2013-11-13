class AddGraphIntervalToMiningRig < ActiveRecord::Migration
  def up
  	add_column :mining_rigs, :graph_interval, :integer, :default => 0
  end

  def down
  	remove_column :mining_rigs, :graph_interval
  end
end
