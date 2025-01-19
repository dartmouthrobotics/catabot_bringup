#!/bin/bash

# TARGET_NETWORK="169.254.0.0"
# while ! ip route get "$TARGET_NETWORK" &> /dev/null; do   echo "Route to $TARGET_NETWORK does not exist. Waiting...";   sleep 5; done

# sudo route del -net 0.0.0.0 netmask 0.0.0.0 dev eth0
# sudo route del -net 169.254.0.0 gw 0.0.0.0 netmask 255.255.0.0
# sudo route add -net 169.254.0.0/16 dev eth1 # lidar on USB connector (eth1)

source /home/catabot-5/catkin_ws/src/catabot_bringup/script/test_connection.sh

until [ `check_ipaddr` -gt 2 ]; do
  sleep 2
done

# configured in setting of network in Ubuntu
sudo route del -net 169.254.0.0 gw 0.0.0.0 netmask 255.255.0.0 dev eth0
sudo route del -net 169.254.0.0 gw 0.0.0.0 netmask 255.255.0.0 dev wlan0

wait_for_ip os-992121000445.local # TODO configuration file

# check if file exists
filename="/dev/pixhawk4"

while [ ! -L "$filename" ]; do
  echo "File $filename does not exist. Waiting..."
  sleep 1
done
echo "File $filename exists."

# check if file exists
target=$(readlink -f "$filename")

while true; do
  if [ -e "$target" ]; then
    echo "$target found!"
    # Do something with ttyACM1 here
    break  # Exit the loop if found
  else
    echo "$target not found, retrying..."
    sleep 1  # Wait for 1 second before retrying
  fi
done

# ROS Master check
wait_for_ip 10.223.142.5 # TODO configuration file

wait_for_process roscore

# ROBOT_NAME=robot_0
ROBOT_NAME=""
source /home/catabot-5/catkin_ws/src/catabot_bringup/script/common_include.sh
exp_date=$(read_experiment_date)
echo "Experiment data $exp_date."
ROS_NAMESPACE=$ROBOT_NAME roslaunch catabot_bringup catabot_bringup.launch experiment_date:=$exp_date
