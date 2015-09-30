class CreateHash < ActiveRecord::Migration
  def change
    create_table :p_hashes do |t|
      t.string :tool
      t.string :p_hash
      t.timestamps null: false
    end
  end
end
