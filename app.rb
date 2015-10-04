require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/multi_route'
require 'lrucache'
require 'guilding-swiftly'

item_map = JSON.parse IO.read 'item_map.json'

cache = LRUCache.new(:ttl => 10 * 60 * 60,
                     :soft_ttl => 60 * 60)

get '/' do
  @title = 'Token Entry'
  erb :token_entry
end

route :get, :post, '/value' do
  @title = 'Dye Value'

  colours = GW2API::get('account/dyes', params)

  @price = colours.each_with_index.map do |colour_id, i|
    puts "#{params['access_token']} - #{i+1} / #{colours.length}"
    cache.fetch colour_id do
      puts "Fetching value for #{colour_id}"
      GW2API::get_value item_map[colour_id.to_s]
    end
  end.inject(:+)

  erb :value
end
