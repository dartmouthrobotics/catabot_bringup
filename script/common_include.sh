#!/bin/bash

source /opt/ros/noetic/setup.bash
source /home/catabot-5/catkin_ws/devel/setup.bash

function field_setup_doodle() {
 unset ROS_HOSTNAME
 export ROS_IP=10.223.142.5
 sudo iptables -P INPUT ACCEPT
 sudo iptables -P OUTPUT ACCEPT
 sudo iptables -P FORWARD ACCEPT
 sudo iptables -F

}
ROBOT_NAME=robot_0
field_setup_doodle
