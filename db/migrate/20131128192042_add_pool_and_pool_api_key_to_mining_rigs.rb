class AddPoolAndPoolApiKeyToMiningRigs < ActiveRecord::Migration
  def up
    add_column :mining_rigs, :pool_name, :string, default: 'eligius'
    add_column :mining_rigs, :pool_api_key, :string
  end

  def down
    remove_column :mining_rigs, :pool_name
    remove_column :mining_rigs, :pool_api_key
  end
end
