pir = 1
dht22 = 2
mqttHost = '192.168.100.122'

chipId = node.chipid()
gpio.mode(pir,gpio.INT)


m = mqtt.Client(chipId, 5)



local function connect()

    m:connect(mqttHost, 1883, 0, function(conn)
	m:publish("events/esp8266/".. chipId .."/status", 
	cjson.encode({type = "status", sensorId = chipId, status = 1,heap = node.heap()}), 0, 0)          
	if DEBUG then 
    	    print("connected") 
	end
     end)

end


m:lwt("events/esp8266/".. chipId .."/status", 
cjson.encode({type = "status", sensorId = chipId, status = 0}), 0, 0)

connect() 


m:on("offline", function(conn)
     if DEBUG then 
        print ("Connecting to the broker ...")
     end
     connect()
end)



gpio.trig(pir,"both", function (level)
        m:publish("events/esp8266/".. chipId .. "/pir" ,
            cjson.encode({type = "PIR", sensorId = chipId, status = level,heap = node.heap()}) ,0,0 )        
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
            print("temperature: "..temp.." deg C")
            print("humidity: "..humi.." %")
            print("Sendind temperature and humidity")
        end
        m:publish("events/esp8266/".. chipId .."/temperature",
            cjson.encode({type = "temperature", sensorId = chipId, temperature = temp, heap = node.heap()})  ,0,0) 
        m:publish("events/esp8266/".. chipId .."/humidity",
            cjson.encode({type = "humidity", sensorId = chipId, humidity = humi ,heap = node.heap()})  ,0,0)
      end

end)
