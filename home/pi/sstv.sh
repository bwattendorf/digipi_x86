#!/bin/bash -x

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
trap ctrl_c TERM
function ctrl_c() {
   echo "CTRL-C pressed, killing qsstv stuff."
   x11vnc -kill :0
   sudo kill `ps aux | grep launch | grep -v grep | awk '{print $2}'`  # novnc socket
   sudo killall qsstv
   sudo sh -c  "echo powersave  > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

   exit 0
}

sudo sh -c  "echo performance  > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

# stop stuff
x11vnc -kill :0
sudo kill `ps aux | grep launch | grep -v grep | awk '{print $2}'`  # novnc socket
sudo killall qsstv 
sudo servivce wsjtx stop

# start stuff
nice -n 5 x11vnc -ncache 10 -display :0 -wait 50 -noxdamage -forever -bg           # runs in background
sleep  5
/home/pi/digibanner.py -b SSTV -s http://digipi/tv              # momentary run
nice -n 5 /usr/share/novnc/utils/launch.sh &                    # this doesn't exit

export DISPLAY=:0   

qsstv &

sleep 8 

sudo renice -n 0 `ps aux | grep qsstv | grep -v grep | awk '{print $2}'`
sudo renice -n 5 `ps aux | grep x11vnc | grep -v grep | awk '{print $2}'`

#maximize app, full screen
wmctrl -a qsstv -b add,maximized_vert,maximized_horz

sleep infinity

echo "URL is http://digipi:6080/vnc.html?host=digipi&port=6080&password=test11&autoconnect=true "



