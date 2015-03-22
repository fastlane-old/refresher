class UpdateChecksController < ApplicationController
  require 'open-uri'
  before_action :set_update_check, only: [:show, :edit, :update, :destroy]


  def check_update
    tool = params[:tool_name]
    version = fetch_version(tool)

    render json: { version: version,
                    status: :ok }

    store_entry(tool)
  end

  def fetch_version(tool)
    Rails.cache.fetch(tool, expires_in: 5.minutes) do
      JSON.parse(open("https://rubygems.org/api/v1/gems/#{tool}.json").read)["version"]
    end
  rescue
    nil
  end

  def store_entry(tool)
    obj = UpdateCheck.find_by_tool(tool)

    unless obj
      obj = UpdateCheck.create(({
        tool: tool,
        data: [],
        count: 0
      }))
    end

    obj.data << Time.now.to_i
    obj.count += 1
    obj.save
  end
end
