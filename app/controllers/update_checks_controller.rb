class UpdateChecksController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  require 'open-uri'

  def check_update
    tool = params[:tool_name]
    version = fetch_version(tool)

    render json: { version: version,
                    status: :ok }

    store_entry(tool, params[:p_hash]) if tool_colors.keys.include?tool.to_sym
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
      codes: "#795548",
      pilot: "#4CA3EB",
      gym: "#7A81FF",
      scan: "#000000",
      supply: "#000000",
    }
  end

  def graphs
    show_fastlane = params[:fastlane] # as fastlane is launched far too often, it's hidden by default

    @data = {}
    @days = []
    start_time = Time.at(1427068800) # the first day we started tracking the launches

    @time = {}
    @time_days = []
    time_start_time = Time.at(1436652000)

    # Number of launches
    # 
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
      @time[bacon.tool] ||= {
        label: bacon.tool,
        fillColor: "rgba(220,220,220,0.2)",
        strokeColor: tool_colors[bacon.tool.to_sym],
        pointColor: tool_colors[bacon.tool.to_sym],
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(220,220,220,1)",
        data: []
      }

      formatted_string = bacon.launch_date.strftime("%d.%m.%Y")
      counter = (bacon.launch_date.to_date - start_time.to_date).to_i
      @data[bacon.tool][:data][counter] ||= 0
      @data[bacon.tool][:data][counter] += bacon.launches
      @days << formatted_string unless @days.include?formatted_string

      if bacon.duration > 0
        counter = (bacon.launch_date.to_date - time_start_time.to_date).to_i
        @time[bacon.tool][:data][counter] ||= (@time[bacon.tool][:data].last || 0)
        @time[bacon.tool][:data][counter] += bacon.duration

        @time_days << formatted_string unless @time_days.include?formatted_string
      end

      # Fill nils with 0, otherwise we have nil in it
      @data[bacon.tool][:data].each_with_index do |k, index|
        @data[bacon.tool][:data][index] ||= 0
      end
      @time[bacon.tool][:data].each_with_index do |k, index|
        @time[bacon.tool][:data][index] ||= 0
      end
    end

    # Sort by # of launches
    @data = @data.sort_by { |name, data| data[:data].sum }.reverse
    @time = @time.sort_by { |name, data| data[:data].sum }.reverse

    # Convert to full hours
    @time.each do |bacon, current|
      current[:data].each_with_index { |value, i| current[:data][i] = (value / 60 / 60) }
    end

    # Now generate cumulative graph
    # 
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

  def store_time
    now = Time.now.to_date
    tool = params[:tool_name]
    obj = Bacon.where(tool: tool, launch_date: now).take

    time = params[:time].to_i
    obj.duration += time
    obj.duration_ci += time if params[:ci]
    obj.save

    render json: {status: :ok}
  end

  def get_durations
    tools = Rails.cache.fetch('duration', expires_in: 2.minutes) do
      tools = {}
      Bacon.all.each do |bacon|
        tools[bacon.tool] ||= 0
        tools[bacon.tool] += bacon.duration
      end
      tools
    end

    render json: tools
  end

  def unique
    all = {}

    PHash.all.each do |a|
      next if (Time.now - a.created_at) > 1.week
      all[a.p_hash] ||= {}
      all[a.p_hash][a.tool] ||= 0
      all[a.p_hash][a.tool] += 1
    end

    all = all.collect { |k, v| v }

    render json: {
      count: all.count,
      raw: all
    }
  end

  private
    def fetch_version(tool)
      Rails.cache.fetch(tool, expires_in: 5.minutes) do
        JSON.parse(open("https://rubygems.org/api/v1/gems/#{tool}.json").read)["version"]
      end
    rescue
      nil
    end

    def store_entry(tool, p_hash)
      now = Time.now.to_date
      obj = Bacon.where(tool: tool, launch_date: now).take

      unless obj
        obj = Bacon.create(({
          tool: tool,
          launches: 0,
          launch_date: now,
          ci: 0,
          duration: 0,
          duration_ci: 0
        }))
      end

      obj.launches += 1
      obj.ci += 1 if params[:ci]
      obj.save

      if p_hash
        obj = PHash.create({
          tool: tool,
          p_hash: p_hash
        })
      end
    end
end
