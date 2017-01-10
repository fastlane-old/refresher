class GeoChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'geo_data'
  end
end
