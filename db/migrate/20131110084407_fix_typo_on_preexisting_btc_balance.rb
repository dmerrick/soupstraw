class FixTypoOnPreexistingBtcBalance < ActiveRecord::Migration
  def up
  	rename_column(:mining_rigs, :preexiting_btc_balance, :preexisting_btc_balance)
  end

  def down
    rename_column(:mining_rigs, :preexisting_btc_balance, :preexiting_btc_balance)
  end
end
