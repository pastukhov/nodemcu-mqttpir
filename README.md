# nodemcu-mqttpir

An app for esp8266 mcu with <a href="https://github.com/nodemcu/nodemcu-firmware">nodemcu firmware</a>
It send temperature/humidity from DHT22 sensor and alerts from PIR motion sensor like <a href"http://ru.aliexpress.com/item/10pcs-HC-SR501-Adjust-IR-Pyroelectric-Infrared-PIR-Motion-Sensor-Detector-Module/1297982338.html">this</a>
Keep in mind that tis sensor use 3.3v logic level,  but should be powered from 5v.

##To get it working you should:
* Define SSID and password in init.lua.
* Define broker in mqttpir.lua.
* Wire DHT22 to GPIO5 and PIR sensor to GPIO4 or any other chosen in mqttpir.lua pir and dht22 variables.

##To upload files you can use MAkefile provided, just type ```make upload```
