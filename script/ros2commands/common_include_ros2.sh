#!/bin/bash

unset ${!ROS@}
source /opt/ros/foxy/setup.bash

function field_setup_doodle() {
 unset ROS_HOSTNAME
 export ROS_IP=10.223.142.5
 sudo iptables -P INPUT ACCEPT
 sudo iptables -P OUTPUT ACCEPT
 sudo iptables -P FORWARD ACCEPT
 sudo iptables -F
}
export ROS_MASTER_URI=http://10.223.142.5:11311
# ROBOT_NAME=robot_0
field_setup_doodle