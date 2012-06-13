require 'redis'

@redis = Redis.new(:host => '127.0.0.1', :port => 6379)

  @redis.subscribe('conquerapp') do |on|
    on.message do |channel, msg|
      puts "REDIS |: #{msg}"
    end
  end