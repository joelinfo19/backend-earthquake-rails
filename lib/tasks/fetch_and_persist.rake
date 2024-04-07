require 'net/http'
require 'json'

namespace :earthquakes do
  desc "Fetch and persist earthquake data"
  task fetch_and_persist: :environment do
    url = URI("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")

    request = Net::HTTP::Get.new(url)
    response = http.request(request)

    if response.code == "200"
      json = JSON.parse(response.body)
      json['features'].each do |feature|

        next if feature['properties']['title'].nil? || feature['properties']['url'].nil? || feature['properties']['place'].nil? || feature['properties']['magType'].nil? || feature['geometry']['coordinates'][0].nil? || feature['geometry']['coordinates'][1].nil?

        magnitude = feature['properties']['mag']
        place = feature['properties']['place']
        time = Time.at(feature['properties']['time'] / 1000)
        url = feature['properties']['url']
        tsunami = feature['properties']['tsunami']
        mag_type = feature['properties']['magType']
        title = feature['properties']['title']
        longitude = feature['geometry']['coordinates'][0]
        latitude = feature['geometry']['coordinates'][1]

        next if Earthquake.exists?(id: feature['id'])
        next if magnitude < -1.0 || magnitude > 10.0
        next if latitude < -90.0 || latitude > 90.0
        next if longitude < -180.0 || longitude > 180.0

        earthquake = Earthquake.new(
          id: feature['id'],
          mag: magnitude,
          place: place,
          time: time,
          url: url,
          tsunami: tsunami,
          mag_type: mag_type,
          title: title,
          longitude: longitude,
          latitude: latitude
        )

        if earthquake.save
          puts "Earthquake saved: #{earthquake.id}"
        else
          puts "Failed to save earthquake: #{earthquake.errors.full_messages}"
        end
      end
    end
  end
end