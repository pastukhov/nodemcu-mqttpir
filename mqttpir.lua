pir = 1
dht22 = 2
mqttHost = '192.168.100.122'
chipId = node.chipid()
gpio.mode(pir,gpio.INT)
mqttClient = mqtt.Client(chipId, 5)

mqttClient:lwt("events/esp8266/".. chipId .."/status",
  cjson.encode({
    type = "status",
    sensorId = chipId,
    status = 0
  }), 0, 0)

mqttClient:on("offline", function()
  if DEBUG then
    print ("Connecting to the broker ...")
  end
  connect()
end)

local function connect()
  mqttClient:connect(mqttHost, 1883, 0, function(conn)
    mqttClient:publish("events/esp8266/".. chipId .."/status",
      cjson.encode({
        type = "status",
        sensorId = chipId,
        status = 1,
        heap = node.heap()
      }), 0, 0)
    if DEBUG then
      print("connected")
    end
  end)
end

local function sendSensors()
  local status, temperature, humidity, temperatureDecimial, humidityDecimial = dht.read(dht22)
  if status == 0 then
    if DEBUG then
      print("temperature: "..temperature.." deg C")
      print("humidity: "..humidity.." %")
      print("Sendind temperature and humidity")
    end
    mqttClient:publish("events/esp8266/".. chipId .."/sensors",
      cjson.encode({
        sensorId = chipId,
        type = "report",
        temperature = temperature,
        temperatureDecimal = temperatureDecimial,
        humidity = humidity ,
        humidityDecimal = humidityDecimial,
	alarm = gpio.read(pir),
        heap = node.heap()
      })  ,0,0)
  end
end

connect()

gpio.trig(pir,"both", sendSensors)

tmr.alarm(2, 10000, 1, sendSensors)
