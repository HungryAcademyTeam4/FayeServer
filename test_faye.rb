require 'faye'
require 'eventmachine'

  EM.run {
    client = Faye::Client.new('http://fallinggarden.com:9000/faye')
    client.subscribe('/rooms/fake') do |message|
      puts message.inspect
    end
    client.publish('/rooms/fake', 'text' => 'It works!')
  }