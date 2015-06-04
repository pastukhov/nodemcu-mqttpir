pir = 1
dht22 = 2
chipid = node.chipid()
broker = "192.168.100.122"
gpio.mode(pir,gpio.INT)

m = mqtt.Client(chipid, 120)
m:lwt("lwt/".. chipid, chipid .." gone offline", 0, 0)
m:connect(broker, 1883, 0, function(conn) print("connected") end)

m:on("offline", function(con)
     print ("Connecting to the broker ...")
     m:connect(broker, 1883, 0, function(conn)
          print("connected") 
     end)

end)

-- on publish message receive event
m:on("message", function(conn, topic, data)
  if data ~= nil then
   print(data)
  end  
end)

gpio.trig(pir,"both", function (level)
        m:publish("events/esp8266/".. chipid .. "/pir" ,
        cjson.encode({Type = "PIR", SensorID = chipid, Status = level}) ,0,0 )
        print(level)
end)


tmr.alarm(2, 10000, 1, function ()
      local t,h =dofile("yet-another-dht22.lc").read(dht22,true)
      if t  and h then
        print("Temperature: "..((t-(t % 10)) / 10).."."..(t % 10).." deg C")
        print("Humidity: "..((h - (h % 10)) / 10).."."..(h % 10).."%")
        print("Sendind temperature and humidity")
        m:publish("events/esp8266/".. chipid .."/temperature",
        cjson.encode({Type = "Temperature", SensorID = chipid, Temperature = ((t-(t % 10)) / 10).."."..(t % 10)})  ,0,0) 
        m:publish("events/esp8266/".. chipid .."/humidity",
        cjson.encode({Type = "Humidity", SensorID = chipid, Humidity = ((h - (h % 10)) / 10).."."..(h % 10)})  ,0,0)
      end

end)
