#!/bin/bash
# startup_bringup.sh, ROS 2 port

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo udevadm control --reload-rules && sudo service udev restart && sudo udevadm trigger
source /opt/ros/humble/setup.bash
source /home/catabot-5/boat_ws/install/setup.bash

# miniahrs_url:=serial:/dev/ttyUSB0:3000000

source "${SCRIPT_DIR}/test_connection.sh"

until [ "$(check_ipaddr)" -gt 2 ]; do
    sleep 2
done

until mountpoint -q /mnt/nova_ssd; do
    echo "Waiting for NVMe..."
    sleep 2
done
#mkdir -p /media/catabot-5/data/datalog/rosbag2

source "${SCRIPT_DIR}/common_include.sh"

#ros2 launch catabot_bringup catabot_bringup.launch.py robot_name:="${ROBOT_NAME}"
ROBOT_NAME=robot_0
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ros2 launch catabot_bringup catabot_bringup.launch.py \
    use_composable:=true \
    use_logging:=true \
    use_pixhawk:=true \
    use_miniAHRS:=true \
    use_ZEDX:=true \
    use_zed_blue:=true \
    use_zed_green:=true \
    use_zed_pink:=true \
    use_zed_red:=true \
    use_lidar:=true \
    use_surface_camera:=false \
    bag_dir:=/home/catabot-5/datalog/rosbag2
