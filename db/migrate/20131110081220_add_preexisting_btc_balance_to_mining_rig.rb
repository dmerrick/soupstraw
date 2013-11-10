class AddPreexistingBtcBalanceToMiningRig < ActiveRecord::Migration
  def up
    change_table :mining_rigs do |t|
      # btc goes to 8 decimal places
      # precision allows values up to 100 bitcoins
      t.decimal :preexiting_btc_balance, :scale => 8, :precision => 11
    end
  end

  def down
    change_table :mining_rigs do |t|
      t.remove :preexiting_btc_balance
    end
  end
end
