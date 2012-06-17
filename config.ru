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
    @connection = Faraday.new(url: http://localhost:3000)
  end
 
  def incoming(msg, callback)
  puts "*****\n\n\n\n"

  puts msg.inspect
  puts msg["introduction"]
  puts msg["channel"]
  puts "*****\n\n\n\n"
    if msg["introduction"]
      @redis.set(msg[:client_id], msg[:user_name])
      @connection.post do |req|
        req.url "/api/v1/chat_rooms"
        req.headers['Content-Type'] = 'application/json'
        req.body = ({chat_room_id: @msg[:chat_room_id], user_name: "System", content: "#{msg[:user_name]} has entered the room."})
      end
    end
    if msg["channel"].split('/').last == "disconnect"
      user_name = @redis.get[:client_id]
      @connection.post do |req|
        req.url "/api/v1/chat_rooms"
        req.headers['Content-Type'] = 'application/json'
        req.body = ({chat_room_id: @msg[:chat_room_id], user_name: "System", content: "#{user_name} has left the room."})
      end
    end
    callback.call(msg)
  end
end

Faye::WebSocket.load_adapter('thin')

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(Broadcaster.new)
faye_server.add_extension(Announcer.new)

run faye_server