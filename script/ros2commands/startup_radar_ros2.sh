#!/bin/bash

while ! ping -c 1 -n -w 1 10.223.142.15 &> /dev/null
  do sleep 1 echo "Ping fail radar"
done
echo "Ping success radar"

source /home/catabot-5/catkin_ws/src/catabot_bringup/script/ros2commands/common_include_ros2.sh
source /home/catabot-5/iasdk-public/ros/ros2/install/setup.bash
unset ROS_LOCALHOST_ONLY
echo "TESTTTTTTTTTTTTTTTTTT"
echo $(env | grep ROS)
cd /home/catabot-5//iasdk-public/ros/ros2/src/nav_launch/launch
ros2 launch nav_launch launch_colossus_publisher.launch.py
