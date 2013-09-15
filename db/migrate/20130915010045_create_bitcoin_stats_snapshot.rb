class CreateBitcoinStatsSnapshot < ActiveRecord::Migration
  def up
  	create_table :bitcoin_stats_snapshots do |t|
  	  # btc goes to 8 decimal places
  	  # precision allows values up to 10k bitcoins mined
      t.decimal :btc_mined, :scale => 8, :precision => 13
      # usd only goes to 2 decimal places
      # precision allows values up to 1 million dollars
      t.decimal :usd_value, :scale => 2, :precision => 10
      # timestamps so we know when the snapshot was taken
      t.timestamps
    end
  end

  def down
  	drop_table :bitcoin_stats_snapshots
  end
end
