God.watch do |w|
  w.log = "/faye.log"
  w.name = "faye"
  w.start = "rainbows /home/deployer/apps/FayeServer/current/faye.ru -c /home/deployer/apps/FayeServer/current/rainbows.conf -E production -p 9000"
  w.keepalive
end