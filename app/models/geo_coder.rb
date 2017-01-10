class GeoCoder
  ##
  # This class will geocode an IP address to it's lat/lon if it matches in the MaxMind city database.
  # The location data is broadcast over a websocket to the geo visualization.
  #
  # No identifying data is saved.

  @@db = MaxMindDB.new(File.join(Rails.root,'vendor', 'assets', 'GeoLite2-City.mmdb'))

  def self.broadcast(ip_addr)
    coder = new(ip_addr)
    if (geo_data = coder.geo_data)
      ActionCable.server.broadcast('geo_data', geo_data)
    end
  end

  def initialize(ip_addr)
    @ip_addr = ip_addr
  end

  def geo_data
    results = @@db.lookup(@ip_addr)
    return nil unless results.found?

    results.to_hash['location']
  end

end
