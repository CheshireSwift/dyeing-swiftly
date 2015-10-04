require 'net/http'
require 'uri'
require 'json'

def get_ids
  jsons = JSON.parse (Net::HTTP.get_response URI('https://www.gw2shinies.com/api/json/idbyname/dye')).body
  jsons.map do |row|
    row['item_id']
  end
end

def get_colour_for_item_id(id)
  item_data = JSON.parse (Net::HTTP.get_response URI.join('https://api.guildwars2.com/v2/items/', id)).body
  item_data['details']['color_id']
end

id_map = {}
ids = get_ids
ids.each_with_index do |item_id, i|
  STDOUT.write "#{i+1} / #{ids.length}\r"
  colour_id = get_colour_for_item_id item_id
  id_map[colour_id] = item_id
end

File.open(ARGV[0], 'w') do |out_file|
  out_file.write(JSON.generate id_map)
end
