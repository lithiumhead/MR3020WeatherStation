# Xively Configuration:
API_KEY="c631a5562a9dc0e28c8894c9c7f16f7ca69e5f74dba268aa1b35dcc622a332c5"
FEED_ID="1882537129"


echo 'Make sure the Sparkfun Weather board is configured with the following settings:'
echo 'Data format: CSV | Units: SI | Pressure: Absolute | baud: 9600 | Sample Rate: 5 seconds'
echo '---------------------------------------------------------------------------------------'
echo ''


LOOP_COUNTER=0

# Serial Port setting
stty -F /dev/ttyUSB0 9600 cs8 -cstopb



# Set the internal field separator to comma
OLDIFS=$IFS
IFS=,

# Loop
while read header_char temp_SHT15 humidity_SHT15 dewpoint_SHT15 presure_BMP085 light_TEMT6000 wind_speed wind_direction rainfall battery trailing_char;
do
 let "LOOP_COUNTER += 1"
 if [ "$LOOP_COUNTER" == "10" ]; then
  logger "Loop Counter error! exiting"
  echo "Loop Counter error! exiting"
  break
 fi
 if [ "$header_char" != "$" ]; then
  continue
 fi
 
    echo " "
 echo "Header character: $header_char"
 echo "SHT15 temperature: $temp_SHT15 deg C"
 echo "SHT15 humidity: $humidity_SHT15 %"
 echo "SHT15 dewpoint: $dewpoint_SHT15 deg C"
 echo "BMP085 pressure (absolute): $presure_BMP085 mbar"
 echo "TEMT6000 light: $light_TEMT6000 %"
 echo "Weather meters wind speed: $wind_speed m/s"
 echo "Weather meters wind direction: $wind_direction degrees"
 echo "Weather meters rainfall: $rainfall mm"
 echo "Battery Voltage: $battery Volts"
 echo "Trailing Character: $trailing_char"
 
 # Restore field separator
 IFS=$OLDIFS
 
 DATA_JSON="{"
 DATA_JSON="$DATA_JSON"$'\n'"  \"version\":\"1.0.0\","
 DATA_JSON="$DATA_JSON"$'\n'"   \"datastreams\" : [ {"
 DATA_JSON="$DATA_JSON"$'\n'"      \"id\" : \"Temperature\","
 DATA_JSON="$DATA_JSON"$'\n'"      \"current_value\" : \"$temp_SHT15\""
 DATA_JSON="$DATA_JSON"$'\n'"    },"
 DATA_JSON="$DATA_JSON"$'\n'"    { \"id\" : \"Humidity\","
 DATA_JSON="$DATA_JSON"$'\n'"      \"current_value\" : \"$humidity_SHT15\""
 DATA_JSON="$DATA_JSON"$'\n'"    },"
 DATA_JSON="$DATA_JSON"$'\n'"    { \"id\" : \"Light\","
 DATA_JSON="$DATA_JSON"$'\n'"      \"current_value\" : \"$light_TEMT6000\""
 DATA_JSON="$DATA_JSON"$'\n'"    },"
 DATA_JSON="$DATA_JSON"$'\n'"    { \"id\" : \"Pressure\","
 DATA_JSON="$DATA_JSON"$'\n'"      \"current_value\" : \"$presure_BMP085\""
 DATA_JSON="$DATA_JSON"$'\n'"    }"
 DATA_JSON="$DATA_JSON"$'\n'"  ]"
 DATA_JSON="$DATA_JSON"$'\n'"}"

 curl --max-time 5 \
  --request PUT \
  --data "$DATA_JSON" \
  --header "X-ApiKey: $API_KEY" \
  --verbose \
  http://api.xively.com/v2/feeds/"$FEED_ID"
 
 #if [ "$?" != 0 ]; then
  echo "Xively PUT Success! (temp=$temp_SHT15, humidity=$humidity_SHT15, light=$light_TEMT6000, pressure=$presure_BMP085)"  
  logger "Xively PUT Success! (temp=$temp_SHT15, humidity=$humidity_SHT15, light=$light_TEMT6000, pressure=$presure_BMP085)"  
 #fi
 break
done < /dev/ttyUSB0

echo "Done!"

# References:
# Arduino OpenWRT USB connection
# http://lectroleevin.wordpress.com/2011/10/26/arduino-openwrt-usb-connection/

# Bash read from ttyUSB0 and send to URL
# http://stackoverflow.com/questions/4942502/bash-read-from-ttyusb0-and-send-to-url

# Change UART serial port speed (baud rate) on OpenWrt
# http://wiki.openwrt.org/doc/recipes/serialbaudratespeed

# Looping through the content of a file in Bash?
# http://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash

# Bash Read Comma Separated CVS File
# http://www.cyberciti.biz/faq/unix-linux-bash-read-comma-separated-cvsfile/

# OpenWRT on TP-Link MR3020 Guide w/USB Support
# http://store.jpgottech.com/support/tp-link-mr3020-openwrt-flashing-guide/

# Rootfs on External Storage (extroot)
# http://wiki.openwrt.org/doc/howto/extroot

# HowTo: Add Jobs To cron Under Linux or UNIX?
# http://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/