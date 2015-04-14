class UpdateChecksController < ApplicationController
  require 'open-uri'
  before_action :set_update_check, only: [:show, :edit, :update, :destroy]


  def check_update
    tool = params[:tool_name]
    version = fetch_version(tool)

    render json: { version: version,
                    status: :ok }

    store_entry(tool) if tool_colors.keys.include?tool.to_sym
  end

  def tool_colors
    {
      fastlane: "black",
      deliver: "#E83F1A",
      snapshot: "#1B7FFB",
      frameit: "#88C258",
      pem: "#8F3DE5",
      sigh: "#1FBCD2",
      produce: "#FCD648",
      cert: "#607D8B",
      codes: "#795548"
    }
  end

  def graphs
    @data = []
    @days = []
    start_time = Time.at(1427068800) # the first day
    step = 1.day

    UpdateCheck.order(:count).reverse.each do |check|
      current = {
        label: check.tool,
        fillColor: "rgba(220,220,220,0.2)",
        strokeColor: tool_colors[check.tool.to_sym],
        pointColor: tool_colors[check.tool.to_sym],
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(220,220,220,1)",
        data: []
      }

      current_time = start_time
      counter = 0
      @days = []
      while current_time <= Time.now
        current[:data][counter] ||= 0
        @days << current_time.strftime("%d.%m.%Y")

        check["data"].each do |t|
          if Time.at(t) > current_time and Time.at(t) < (current_time + step)
            current[:data][counter] += 1
          end
        end

        current_time += step
        counter += 1
      end

      @data << current
    end

    # Now generate cumulative graph
    @cumulative = []
    @data.each do |current|
      new_val = current.dup
      new_data = []
      new_val[:data].each_with_index do |value, i|
        new_data[i] = value + (new_data[-1] || 0)
      end
      new_val[:data] = new_data
      @cumulative << new_val
    end
  end

  def stats
    data = {}
    UpdateCheck.order(:count).reverse.each { |t| data[t.tool] = t.count }
    render json: JSON.pretty_generate(data)
  end

  private
    def fetch_version(tool)
      Rails.cache.fetch(tool, expires_in: 5.minutes) do
        JSON.parse(open("https://rubygems.org/api/v1/gems/#{tool}.json").read)["version"]
      end
    rescue
      nil
    end

    def store_entry(tool)
      now = Time.now.to_date + 1.day
      obj = Bacon.where(tool: tool, launch_date: now).take

      unless obj
        obj = Bacon.create(({
          tool: tool,
          launches: 0,
          launch_date: now
        }))
      end

      obj.launches += 1
      obj.save
    end
end
