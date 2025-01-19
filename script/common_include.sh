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
# ROBOT_NAME=robot_0
field_setup_doodle

function read_index() 
{
    cat "/home/catabot-5/index.txt";
}

# function update_index() {
#     filename="/home/catabot-5/index.txt"
#     counter=$(cat $filename)
#     ((counter++))
#     echo "$counter" > $filename
# }

# # first
# function update_experiment_date() {
#     filename="/home/catabot-5/index.txt"
    
#     # Generate a timestamp
#     CURRENT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")

#     echo "$CURRENT_TIME" > $filename
# }

# after
function read_experiment_date()
{
    cat "/home/catabot-5/index.txt";
}
