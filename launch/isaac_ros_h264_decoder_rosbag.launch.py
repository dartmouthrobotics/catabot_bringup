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
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch.substitutions import PathJoinSubstitution
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    """Launch stereo H.264 decoder with rosbag playback."""
    launch_args = [
        DeclareLaunchArgument(
            'rosbag_path',
            description='Path of the rosbag'
        ),
        DeclareLaunchArgument(
            'camera_topic_prefix',
            default_value='/blue/zed',
            description='Base camera topic prefix. Example: /red/red_zedx_sn42151672'
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
        )
    ]

    rosbag_path = LaunchConfiguration('rosbag_path')
    camera_topic_prefix = LaunchConfiguration('camera_topic_prefix')
    container_name = LaunchConfiguration('container_name')
    log_level = LaunchConfiguration('log_level')

    decoder_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([
            PathJoinSubstitution([
                FindPackageShare('catabot_bringup'),
                'launch',
                'isaac_ros_h264_decoder.launch.py',
            ])
        ]),
        launch_arguments={
            'camera_topic_prefix': camera_topic_prefix,
            'stereo': 'true',
            'container_name': container_name,
            'log_level': log_level,
            'play_rosbag': 'true',
            'rosbag_path': rosbag_path,
        }.items(),
    )

    return launch.LaunchDescription(launch_args + [decoder_launch])
