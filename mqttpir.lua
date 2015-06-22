pir = 1
dht22 = 2
chipid = node.chipid()
gpio.mode(pir,gpio.INT)

m = mqtt.Client(chipid, 5)



local function connect()

m:connect("192.168.100.122", 1883, 0, function(conn)
    m:publish("events/esp8266/".. chipid .."/status", 
    cjson.encode({Type = "Status", SensorID = chipid, Status = 1,Heap = node.heap()}), 0, 0)          
    if DEBUG then 
       print("connected") 
    end
     end)

end



m:lwt("events/esp8266/".. chipid .."/status", 
cjson.encode({Type = "Status", SensorID = chipid, Status = 0}), 0, 0)

connect() 


m:on("offline", function(conn)
     if DEBUG then 
        print ("Connecting to the broker ...")
     end
     connect()
end)



gpio.trig(pir,"both", function (level)
        m:publish("events/esp8266/".. chipid .. "/pir" ,
            cjson.encode({Type = "PIR", SensorID = chipid, Status = level,Heap = node.heap()}) ,0,0 )        
        if DEBUG then 
            print(level)
        end
end)


tmr.alarm(2, 10000, 1, function ()
      local status, temp, humi, temp_decimial, humi_decimial = dht.read(dht22)
      
      if status == 0 then
        temp = tostring(temp) ..'.'.. tostring(temp_decimial):gsub('0+$','')
        humi = tostring(humi) ..'.'.. tostring(humi_decimial):gsub('0+$','')

        if DEBUG then 
            print("Temperature: "..temp.." deg C")
            print("Humidity: "..humi.." %")
            print("Sendind temperature and humidity")
        end
        m:publish("events/esp8266/".. chipid .."/temperature",
            cjson.encode({Type = "Temperature", SensorID = chipid, Temperature = temp, Heap = node.heap()})  ,0,0) 
        m:publish("events/esp8266/".. chipid .."/humidity",
            cjson.encode({Type = "Humidity", SensorID = chipid, Humidity = humi ,Heap = node.heap()})  ,0,0)
      end

end)
