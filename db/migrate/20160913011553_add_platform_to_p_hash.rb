class AddPlatformToPHash < ActiveRecord::Migration
  def change
    add_column :p_hashes, :platform, :string
  end
end
