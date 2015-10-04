require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/multi_route'
require 'cachy'
require 'active_support/core_ext/numeric/time'
require 'active_support/cache'
require 'guilding-swiftly'

item_map = JSON.parse IO.read 'item_map.json'

Cachy.cache_store = ActiveSupport::Cache::MemoryStore.new

get '/' do
  @title = 'Token Entry'
  erb :token_entry
end

route :get, :post, '/value' do
  @title = 'Dye Value'

  colours = GW2API::get 'account/dyes', params

  @price = colours.each_with_index.map do |colour_id, i|
    puts "#{params['access_token']} - #{i+1} / #{colours.length}"
    Cachy.cache colour_id.to_s.to_sym, :expires_in => 1.hour do
      puts "Fetching value for #{colour_id}"
      GW2API::get_value item_map[colour_id.to_s]
    end
  end.inject :+

  erb :value
end
