require 'faraday'

class AnalyticIngesterLaunchedWorker
  @queue = :analytic_ingester

  def self.perform(p_hash, tool, platform, ci, timestamp_seconds)
    start = Time.now

    analytics = []
    analytics << event_for_p_hash(p_hash, tool, platform, timestamp_seconds) if p_hash
    analytics << event_for_bacon(tool, ci, timestamp_seconds)

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

  def self.event_for_p_hash(p_hash, tool, platform, timestamp_seconds)
    {
      event_source: {
        oauth_app_name: 'fastlane-refresher',
        product: 'fastlane'
      },
      actor: {
        name:'project',
        detail: p_hash
      },
      action: {
        name: 'update_checked'
      },
      primary_target: {
        name: 'tool',
        detail: tool || 'unknown'
      },
      secondary_target: {
        name: 'platform',
        detail: platform || 'unknown'
      },
      millis_since_epoch: timestamp_seconds * 1000,
      version: 1
    }
  end

  def self.event_for_bacon(tool, ci, timestamp_seconds)
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
        name: 'launched'
      },
      primary_target: {
        name: 'ci',
        detail: ci.present?.to_s
      },
      millis_since_epoch: timestamp_seconds * 1000,
      version: 1
    }
  end
end
