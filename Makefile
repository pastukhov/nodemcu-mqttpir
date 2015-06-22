######################################################################
# User configuration
######################################################################
# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
# Please check that is in your path or provire the full path to:
NODEMCU-UPLOADER=nodemcu-uploader.py
# Serial port
PORT=/dev/ttyUSB0
SPEED=230400

######################################################################
# End of user config
######################################################################
LUA_FILES := init.lua mqttpir.lua

# Print usage
usage:
	@echo "make upload to upload"
	@echo $(TEST)

# Upload lua files
upload: $(LUA_FILES)
	@$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(foreach f, $^, $(f))
