require 'faye'
Faye::WebSocket.load_adapter('thin')
faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(Debugger)
run faye_server

class Debugger
  def incoming(msg)
    puts msg.inspect
  end
end