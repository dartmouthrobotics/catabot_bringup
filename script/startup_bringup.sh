#!/bin/bash

# TARGET_NETWORK="169.254.0.0"
# while ! ip route get "$TARGET_NETWORK" &> /dev/null; do   echo "Route to $TARGET_NETWORK does not exist. Waiting...";   sleep 5; done

# sudo route del -net 0.0.0.0 netmask 0.0.0.0 dev eth0
# sudo route del -net 169.254.0.0 gw 0.0.0.0 netmask 255.255.0.0
# sudo route add -net 169.254.0.0/16 dev eth1 # lidar on USB connector (eth1)

# ROS Master check
while ! ping -c 1 -n -w 1 10.223.142.5 &> /dev/null
  do sleep 1 echo "Ping fail eth0"
done
echo "Ping success eth0"

# ouster ping pre-requisite
while ! ping -c 1 -n -w 1 os-992121000445.local &> /dev/null
  do sleep 1 echo "Ping fail ouster"
done
echo "Ping success ouster"

# configured in setting of network in Ubuntu
sudo route del -net 169.254.0.0 gw 0.0.0.0 netmask 255.255.0.0 dev eth0
sudo route del -net 169.254.0.0 gw 0.0.0.0 netmask 255.255.0.0 dev wlan0

source /home/catabot-5/catkin_ws/src/catabot_bringup/script/test_connection.sh

until [ `check_ipaddr` -gt 2 ]; do
  sleep 2
done

# check if file exists
filename="/dev/pixhawk4"

while [ ! -L "$filename" ]; do
  echo "File $filename does not exist. Waiting..."
  sleep 1
done

echo "File $filename exists."
# ROBOT_NAME=robot_0
ROBOT_NAME=""
source /home/catabot-5/catkin_ws/src/catabot_bringup/script/common_include.sh
ROS_NAMESPACE=$ROBOT_NAME roslaunch catabot_bringup catabot_bringup.launch
