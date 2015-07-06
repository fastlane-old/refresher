class UpdateChecksController < ApplicationController
  require 'open-uri'

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
    show_fastlane = params[:fastlane] # as fastlane is launched far too often, it's hidden by default

    @data = {}
    @days = []
    start_time = Time.at(1427068800) # the first day we started tracking the launches

    Bacon.all.order(:launch_date).each do |bacon|
      next if (!show_fastlane and bacon.tool == 'fastlane')

      @data[bacon.tool] ||= {
        label: bacon.tool,
        fillColor: "rgba(220,220,220,0.2)",
        strokeColor: tool_colors[bacon.tool.to_sym],
        pointColor: tool_colors[bacon.tool.to_sym],
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(220,220,220,1)",
        data: []
      }

      counter = (bacon.launch_date.to_date - start_time.to_date).to_i

      @data[bacon.tool][:data][counter] ||= 0
      @data[bacon.tool][:data][counter] += bacon.launches

      # Fill nils with 0
      @data[bacon.tool][:data].each_with_index do |k, index|
        @data[bacon.tool][:data][index] ||= 0
      end

      formatted_string = bacon.launch_date.strftime("%d.%m.%Y")
      @days << formatted_string unless @days.include?formatted_string
    end

    # Sort by # of launches
    @data = @data.sort_by { |name, data| data[:data].sum }.reverse

    # Now generate cumulative graph
    @cumulative = []
    @data.each do |key, current|
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
    Bacon.all.order(:launches).reverse.each do |t| 
      data[t.tool] ||= 0
      data[t.tool] += t.launches
    end
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
      now = Time.now.to_date
      obj = Bacon.where(tool: tool, launch_date: now).take

      unless obj
        obj = Bacon.create(({
          tool: tool,
          launches: 0,
          launch_date: now,
          ci: 0
        }))
      end

      obj.launches += 1
      obj.ci += 1 if params[:ci]
      obj.save
    end
end
