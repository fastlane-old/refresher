class CreateBacons < ActiveRecord::Migration
  def change
    create_table :bacons do |t|
      t.string :tool
      t.date :launch_date
      t.integer :launches

      t.timestamps null: false
    end

    # Migrate existing data
    start_time = Time.at(1427068800) # the first day
    step = 1.day

    UpdateCheck.order(:count).reverse.each do |check|
      current_time = start_time
      while current_time <= Time.now
        current = {
          tool: check.tool,
          launches: 0,
          launch_date: current_time.to_date
        }

        check["data"].each do |t|
          if Time.at(t) > current_time and Time.at(t) < (current_time + step)
            current[:launches] += 1
          end
        end

        if current[:launches] > 0
          Bacon.create!(current)
          puts current
        end

        current_time += step
      end
    end
  end
end
