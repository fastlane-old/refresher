class AddCiToBacons < ActiveRecord::Migration
  def change
    add_column :bacons, :ci, :integer

    Bacon.all.each do |bacon|
      bacon.ci = 0
      bacon.save
    end
  end
end
