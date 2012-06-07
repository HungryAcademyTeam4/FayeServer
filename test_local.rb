require 'faye'
require 'eventmachine'

  EM.run {
    client = Faye::Client.new('http://localhost:9000/faye')
    client.subscribe('/room') do |message|
      puts message.inspect
    end
    client.publish('/room', message: {'text' => 'It works (for reals)!'})
  }