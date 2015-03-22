class CreateUpdateChecks < ActiveRecord::Migration
  def change
    create_table :update_checks, id: false do |t|
      t.primary_key :tool, :id
      t.string :tool
      t.string :data
      
      t.timestamps null: false
    end
  end
end
