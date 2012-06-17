require 'faye'
require 'redis'
require 'json'

class Broadcaster
  
  def initialize
    @redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  end

  def incoming(msg, callback)
    puts msg
    @redis.publish("conquerapp", {msg: msg}.to_json) if msg["data"]
    callback.call(msg)
  end
end

Faye::WebSocket.load_adapter('rainbows')

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(Broadcaster.new)
run faye_server