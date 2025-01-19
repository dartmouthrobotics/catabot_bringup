#!/bin/bash

# Ensure ROS 2 is properly sourced
source /home/catabot-5/catkin_ws/src/catabot_bringup/script/ros2commands/common_include_ros2.sh
source /home/catabot-5/iasdk-public/ros/ros2/install/setup.bash


BASE_DIR="/home/catabot-5/datalog/rosbag2"


# Ensure the base directory exists
mkdir -p $BASE_DIR

# # Generate a timestamp
CURRENT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")

experiment_date=$(read_experiment_date)_$CURRENT_TIME

# Combine prefix and timestamp for folder name
OUTPUT_DIR="${BASE_DIR}/${experiment_date}"

# Topics to record
TOPICS=(
  "/radar_data/configuration_data"
  "/radar_data/fft_data"
)


# Record the topics using ros2 bag (default naming by system time)
ros2 bag record -o $OUTPUT_DIR ${TOPICS[@]}
