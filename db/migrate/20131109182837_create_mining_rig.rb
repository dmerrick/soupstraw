class CreateMiningRig < ActiveRecord::Migration
  def self.up
    create_table :mining_rigs do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :mining_rigs
  end
end
