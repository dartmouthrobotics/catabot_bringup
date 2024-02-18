#!/bin/bash

source /home/catabot-5/catkin_ws/src/catabot_bringup/script/test_connection.sh

until [ `check_ipaddr` -gt 2 ]; do
  sleep 2
done

ROBOT_NAME=robot_0
source /home/catabot-5/catkin_ws/src/catabot_bringup/script/common_include.sh
ROS_NAMESPACE=$ROBOT_NAME roslaunch catabot_bringup catabot_bringup.launch
