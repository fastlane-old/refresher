class AddTimeToBacon < ActiveRecord::Migration
  def change
    add_column :bacons, :duration, :integer
    add_column :bacons, :duration_ci, :integer

    Bacon.all.each do |bacon|
      bacon.duration = 0
      bacon.duration_ci = 0
      bacon.save
    end
  end
end
