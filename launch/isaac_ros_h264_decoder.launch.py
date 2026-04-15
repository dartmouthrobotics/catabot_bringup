# SPDX-FileCopyrightText: NVIDIA CORPORATION & AFFILIATES
# Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

import launch
import os
import re
import yaml
from launch.actions import DeclareLaunchArgument, ExecuteProcess, LogInfo, OpaqueFunction
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import ComposableNodeContainer
from launch_ros.descriptions import ComposableNode
from ament_index_python.packages import get_package_share_directory


def _load_zed_camera_config():
    config_path = os.path.join(
        get_package_share_directory('catabot_bringup'),
        'param/zed_cameras.yaml',
    )
    with open(config_path, 'r') as config_file:
        return yaml.safe_load(config_file)


def _camera_topic_prefix(camera_config, camera_name):
    normalized_name = camera_name.strip().strip('/').lower()
    camera_info = camera_config.get('cameras', {}).get(normalized_name)
    if camera_info is None:
        # Also accept a full camera token like "green_zedx_sn47983353".
        token_match = re.fullmatch(r'([a-z0-9_]+)_zedx_sn(\d+)', normalized_name)
        if token_match:
            token_name, token_serial = token_match.groups()
            return f'/{token_name}/{token_name}_zedx_sn{token_serial}'

        available_cameras = ', '.join(sorted(camera_config.get('cameras', {}).keys()))
        raise ValueError(f'Unknown camera_name: {camera_name}. Available cameras: {available_cameras}')

    serial_number = str(camera_info['serial_number'])
    return f'/{normalized_name}/{normalized_name}_zedx_sn{serial_number}'


def _build_decoder_node(name, compressed_topic, uncompressed_topic):
    return ComposableNode(
        name=name,
        package='isaac_ros_h264_decoder',
        plugin='nvidia::isaac_ros::h264_decoder::DecoderNode',
        remappings=[
            ('image_compressed', compressed_topic),
            ('image_uncompressed', uncompressed_topic)
        ]
    )


def _launch_setup(context, *args, **kwargs):
    camera_config = _load_zed_camera_config()
    camera_name = LaunchConfiguration('camera_name').perform(context)
    camera_topic_prefix = LaunchConfiguration('camera_topic_prefix').perform(context).rstrip('/')
    stereo = LaunchConfiguration('stereo').perform(context).lower() == 'true'
    camera_side = LaunchConfiguration('camera_side').perform(context)
    container_name = LaunchConfiguration('container_name').perform(context)
    log_level = LaunchConfiguration('log_level').perform(context)
    play_rosbag = LaunchConfiguration('play_rosbag').perform(context).lower() == 'true'
    rosbag_path = LaunchConfiguration('rosbag_path').perform(context)

    if not camera_topic_prefix:
        camera_topic_prefix = _camera_topic_prefix(camera_config, camera_name)

    actions = []

    actions.append(
        LogInfo(msg=f'isaac_ros_h264_decoder: using camera_topic_prefix={camera_topic_prefix}')
    )

    left_image_compressed_topic = f'{camera_topic_prefix}/left/color/raw/image/compressed'
    left_image_uncompressed_topic = f'{camera_topic_prefix}/left/color/raw/image'
    right_image_compressed_topic = f'{camera_topic_prefix}/right/color/raw/image/compressed'
    right_image_uncompressed_topic = f'{camera_topic_prefix}/right/color/raw/image'

    if play_rosbag:
        actions.append(
            ExecuteProcess(
                cmd=['ros2', 'bag', 'play', '--loop', rosbag_path],
                output='screen'
            )
        )

    if stereo:
        decoder_nodes = [
            _build_decoder_node(
                'left_decoder_node',
                left_image_compressed_topic,
                left_image_uncompressed_topic,
            ),
            _build_decoder_node(
                'right_decoder_node',
                right_image_compressed_topic,
                right_image_uncompressed_topic,
            ),
        ]
    else:
        side = 'right' if camera_side == 'right' else 'left'
        decoder_nodes = [
            _build_decoder_node(
                f'{side}_decoder_node',
                f'{camera_topic_prefix}/{side}/color/raw/image/compressed',
                f'{camera_topic_prefix}/{side}/color/raw/image',
            )
        ]

    actions.append(
        ComposableNodeContainer(
            name=container_name,
            namespace='',
            package='rclcpp_components',
            executable='component_container_mt',
            composable_node_descriptions=decoder_nodes,
            output='screen',
            arguments=['--ros-args', '--log-level', log_level]
        )
    )

    return actions


def generate_launch_description():
    """Launch H.264 decoder node(s) with optional rosbag playback.

    For replay-focused usage examples, see isaac_ros_h264_decoder_rosbag.launch.py.
    """
    launch_args = [
        DeclareLaunchArgument(
            'camera_name',
            default_value='blue',
            description='Camera name from param/zed_cameras.yaml'
        ),
        DeclareLaunchArgument(
            'camera_topic_prefix',
            default_value='',
            description='Optional explicit camera topic prefix. If empty, derive from camera_name using param/zed_cameras.yaml'
        ),
        DeclareLaunchArgument(
            'stereo',
            default_value='false',
            description='If true, decode both left and right streams'
        ),
        DeclareLaunchArgument(
            'camera_side',
            default_value='left',
            description='When stereo is false, which side to decode: left or right'
        ),
        DeclareLaunchArgument(
            'container_name',
            default_value='decoder_container',
            description='Name of the composable node container'
        ),
        DeclareLaunchArgument(
            'log_level',
            default_value='info',
            description='ROS log level for the decoder container'
        ),
        DeclareLaunchArgument(
            'play_rosbag',
            default_value='false',
            description='If true, run ros2 bag play --loop'
        ),
        DeclareLaunchArgument(
            'rosbag_path',
            default_value='',
            description='Path of the rosbag (used only when play_rosbag is true)'
        )
    ]

    return launch.LaunchDescription(launch_args + [OpaqueFunction(function=_launch_setup)])
