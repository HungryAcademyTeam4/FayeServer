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
  end

  def incoming(msg, callback)
    puts "\n\n\n\n*******************************************************"

    puts msg.inspect
    puts msg["data"]["introduction"] rescue "no data"
    puts msg["channel"]
    puts "*******************************************************\n\n\n\n"
      if msg["data"] && msg["data"]["introduction"]
        @redis.set(msg[:client_id], msg[:user_name])
        url = 'http://localhost:9000/faye'
        body = {
          channel: msg["channel"],
          data: {
            chat_room_id: msg["channel"].split("/").last,
            user_name: "System",
            content: "#{msg[:user_name]} has entered the room."
          }
        }
        Net::HTTP.post_form(URI.parse(url), message: body.to_json)
      end
    end
  end
end

Faye::WebSocket.load_adapter('thin')

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(Broadcaster.new)
# faye_server.add_extension(Announcer.new)

run faye_server