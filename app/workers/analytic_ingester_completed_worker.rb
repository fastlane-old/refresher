require 'faraday'

class AnalyticIngesterCompletedWorker
  @queue = :analytic_ingester

  def self.perform(tool, ci, install_method, duration, timestamp_seconds)
    start = Time.now

    analytics = []
    analytics << event_for_completion(tool, ci, duration, timestamp_seconds)
    analytics << event_for_install_method(tool, ci, install_method, timestamp_seconds)

    analytic_event_body = { analytics: analytics }.to_json

    puts "Sending analytic event: #{analytic_event_body}"

    response = Faraday.new(:url => ENV["ANALYTIC_INGESTER_URL"]).post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = analytic_event_body
    end

    stop = Time.now

    puts "Analytic ingester response was: #{response.status}"
    puts "Sending analytic ingester event took #{(stop - start) * 1000}ms"
  end

  def self.event_for_completion(tool, ci, duration, timestamp_seconds)
    {
      event_source: {
        oauth_app_name: 'fastlane-refresher',
        product: 'fastlane'
      },
      actor: {
        name:'tool',
        detail: tool || 'unknown'
      },
      action: {
        name: 'completed_with_duration'
      },
      primary_target: {
        name: 'duration',
        detail: duration.to_s
      },
      secondary_target: {
        name: 'ci',
        detail: ci.present?.to_s
      },
      millis_since_epoch: timestamp_seconds * 1000,
      version: 1
    }
  end

  def self.event_for_install_method(tool, ci, install_method, timestamp_seconds)
    {
      event_source: {
        oauth_app_name: 'fastlane-refresher',
        product: 'fastlane'
      },
      actor: {
        name:'tool',
        detail: tool || 'unknown'
      },
      action: {
        name: 'completed_with_install_method'
      },
      primary_target: {
        name: 'install_method',
        detail: install_method || 'unknown'
      },
      secondary_target: {
        name: 'ci',
        detail: ci.present?.to_s
      },
      millis_since_epoch: timestamp_seconds * 1000,
      version: 1
    }
  end
end
