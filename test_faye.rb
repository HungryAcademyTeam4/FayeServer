require 'faye'
require 'eventmachine'

  EM.run {
    client = Faye::Client.new('http://fallinggarden.com:9000/faye')
    client.subscribe('/1') do |message|
      puts message.inspect
    end
    client.publish('/1', 'text' => 'It works!')
  }