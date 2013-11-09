class AddDateStartedAndWalletAddressToMiningRig < ActiveRecord::Migration
  def up
  	change_table :mining_rigs do |t|
	  t.datetime :start_date
	  t.string :wallet_address
	end
  end

  def down
  	 change_table :mining_rigs do |t|
	  t.remove :start_date
	  t.remove :wallet_address
	end
  end
end
