class AddActiveToMiningRigs < ActiveRecord::Migration
  def up
    add_column :mining_rigs, :active, :boolean, default: true
  end

  def down
    remove_column :mining_rigs, :active
  end
end
