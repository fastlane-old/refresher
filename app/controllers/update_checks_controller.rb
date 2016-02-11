class UpdateChecksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :authenticate, only: [:weekly, :graphs, :stats]

  require 'open-uri'

  def check_update
    tool = params[:tool_name]
    version = fetch_version(tool)

    render json: { version: version,
                    status: :ok }

    store_entry(tool, params[:p_hash]) if tool_colors.keys.include?tool.to_sym
  end

  def weekly
    count = {}
    Bacon.all.order(:launch_date).each do |bacon|
      next unless bacon.launch_date > Time.now - 7.days
      count[bacon.tool] ||= 0
      count[bacon.tool] += bacon.launches
    end
    render json: count.sort_by { |k, v| v }.reverse.to_h
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
      watchbuild: "#000000",
      match: "#000000",
      screengrab: "#257E6D"
    }
  end

  def graphs
    show_fastlane = params[:fastlane] # as fastlane is launched far too often, it's hidden by default

    @data = {}
    @days = []

    if params[:weeks]
      start_time = Time.now - params[:weeks].to_i.weeks
    else
      start_time = Time.at(1427068800) # the first day we started tracking the launches
    end

    overall_sum = 0
    ci_sum = 0

    # Number of launches
    # 
    Bacon.all.order(:launch_date).each do |bacon|
      next if (!show_fastlane and bacon.tool == 'fastlane')
      next if (bacon.launch_date < start_time)

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

      formatted_string = bacon.launch_date.strftime("%d.%m.%Y")
      counter = (bacon.launch_date.to_date - start_time.to_date).to_i
      @data[bacon.tool][:data][counter] ||= 0
      if params[:ci].to_i > 0
        @data[bacon.tool][:data][counter] += bacon.ci
      else
        @data[bacon.tool][:data][counter] += bacon.launches
      end
      overall_sum += bacon.launches
      ci_sum += bacon.ci

      @days << formatted_string unless @days.include?formatted_string

      # Fill nils with 0, otherwise we have nil in it
      @data[bacon.tool][:data].each_with_index do |k, index|
        @data[bacon.tool][:data][index] ||= 0
      end
    end

    @ci_ratio = (ci_sum.to_f / overall_sum.to_f) * 100

    # Sort by # of launches
    @data = @data.sort_by { |name, data| data[:data].sum }.reverse

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
    if params[:weeks]
      coll = Bacon.where(created_at: (Time.now - params[:weeks].to_i.weeks)..Time.now)
    else
      coll = Bacon.all
    end

    coll.order(:launches).reverse.each do |t| 
      data[t.tool] ||= 0
      if params[:ci].to_i > 0
        data[t.tool] += t.ci
      else
        data[t.tool] += t.launches
      end
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

    start = Time.now - 1.week
    finish = Time.now
    PHash.where(created_at: start..finish).each do |a|
      all[a.p_hash] ||= {}
      all[a.p_hash][a.tool] = 1
    end

    all = all.collect { |k, v| v }

    render json: {
      count: all.count,
      raw: all
    }
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == "admin" && password == ENV["FL_PASSWORD"]
      end
    end

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
