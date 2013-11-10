class AddCostOfMinerToMiningRig < ActiveRecord::Migration
  def up
    change_table :mining_rigs do |t|
      # btc goes to 8 decimal places
      # precision allows values up to 100 bitcoins per rig
      t.decimal :btc_cost, :scale => 8, :precision => 11
      # usd only goes to 2 decimal places
      # precision allows values up to $100k per rig
      t.decimal :usd_cost, :scale => 2, :precision => 9
    end
  end

  def down
    change_table :mining_rigs do |t|
      t.remove :btc_cost
      t.remove :usd_cost
    end
  end
end
