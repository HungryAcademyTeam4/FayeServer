require 'faye'

class Debugger
  def incoming(msg, callback)
    puts msg.inspect

    callback.call(msg)
  end
end


Faye::WebSocket.load_adapter('thin')
faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(Debugger.new)
run faye_server

