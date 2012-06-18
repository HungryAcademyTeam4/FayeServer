require 'faye'
require 'redis'
require 'json'
require 'faraday'

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

class Announcer

  def initialize
    @redis = Redis.new(:host => '127.0.0.1', :port => 6379)
    @faye_client = Faye::Client.new('http://fallinggarden.com:9000/faye')
  end

  def incoming(msg, callback)
    puts "\n\n\n\n*******************************************************"

    puts msg.inspect
    puts msg["data"]["introduction"] rescue "no data"
    puts msg["channel"]
    puts "*******************************************************\n\n\n\n"
    if msg["data"] && msg["data"]["introduction"]
      body = get_body_from_msg(msg)
      @faye_client.publish(msg["channel"], body)
    end
    callback.call(msg)
  end

  def get_body_from_msg(msg)
      {
       chat_room_id: msg["channel"].split("/").last,
       user_name: "System",
       content: "#{msg["data"]["user_name"]} has entered the room."
      }
  end
end


Faye::WebSocket.load_adapter('thin')

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(Broadcaster.new)
faye_server.add_extension(Announcer.new)

run faye_server