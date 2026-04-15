
## Blueboat configuration
1. pixhawk __fcu_url__: ud[://14500@] and there is no baudrate parameter.
2. new Ouster driver doesn't need `metadata` as an argument. We need to set `sensor_hostname` as `os-serialnumber.local` and `udp_dest` as computer's ip connected to LiDAR.
    a. need to record `/ouster/metadata` based on the new ROS driver

## launch
Use a single entrypoint with a mode switch.

Standalone nodes (default):
```bash
ros2 launch catabot_bringup catabot_bringup.launch.py use_composable:=false
```

Composable nodes:
```bash
ros2 launch catabot_bringup catabot_bringup.launch.py use_composable:=true
```

## replay
* `TIME_FROM_ROS_TIME` is essential to retrieve the time when the bag file is recorded and time sync.
```
roslaunch ouster_ros replay.launch bag_file:=/home/catabot-4/datalog/rosbag/catabot-4_2025-10-08-20-21-20.bag timestamp_mode:=TIME_FROM_ROS_TIME
```

### H.264 decoder replay

Use the rosbag decoder wrapper when replaying compressed ZED image topics from a recorded bag.

Generic form:
```bash
ros2 launch catabot_bringup isaac_ros_h264_decoder_rosbag.launch.py \
    rosbag_path:=/path/to/bag \
    camera_name:=green
```

Concrete example:
```bash
ros2 launch catabot_bringup isaac_ros_h264_decoder_rosbag.launch.py \
    rosbag_path:=/mnt/nova_ssd/datalog/rosbag2/2026-04-15-18-06-19/green_zedx_sn47983353_2026-04-15-18-06-29 \
    camera_name:=green
```

If needed, you can bypass `camera_name` and set the full topic prefix directly:
```bash
ros2 launch catabot_bringup isaac_ros_h264_decoder_rosbag.launch.py \
    rosbag_path:=/path/to/bag \
    camera_topic_prefix:=/green/green_zedx_sn47983353
```

## checking

1. running
```
rviz
```
* fixed_frame: os_sensor
* topic: 
    * ouster_points
    * usb_surface_cam/image_raw/compressed
    * mavros/vfr_hub: 

2. replay
```
rostopic echo /ouster/points/header
```
