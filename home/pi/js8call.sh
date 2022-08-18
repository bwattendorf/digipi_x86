#!/bin/bash -x

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
trap ctrl_c TERM
function ctrl_c() {
   echo "CTRL-C pressed, killing js8call stuff."
   x11vnc -kill :0
   sudo kill `ps aux | grep launch | grep -v grep | awk '{print $2}'`  # novnc socket
   sudo killall js8call
   sudo sh -c  "echo powersave  > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

   exit 0
}

sudo sh -c  "echo performance  > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

# stop stuff
x11vnc -kill :0
sudo kill `ps aux | grep launch | grep -v grep | awk '{print $2}'`  # novnc socket
sudo killall js8call 

# start stuff
nice -n 5 x11vnc -ncache 10 -display :0 -wait 50 -noxdamage -forever -bg                  # runs in background
sleep  5
/home/pi/digibanner.py -b JS8Call -s http://digipi/js8      # exits quickly
nice -n 5 /usr/share/novnc/utils/launch.sh &                # this doesn't exit

export DISPLAY=:0   

js8call &

sleep 14

#maximize app, full screen
wmctrl -a js8call -b add,maximized_vert,maximized_horz

sudo renice -n 0 `ps aux | grep js8call | grep -v grep | awk '{print $2}'`
sudo renice -n 5 `ps aux | grep x11vnc | grep -v grep | awk '{print $2}'`

sleep infinity




