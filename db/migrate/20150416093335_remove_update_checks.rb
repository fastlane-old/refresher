class RemoveUpdateChecks < ActiveRecord::Migration
  def change
    drop_table :update_checks
  end
end
