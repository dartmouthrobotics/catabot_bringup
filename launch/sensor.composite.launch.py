# Copyright 2023 Ouster, Inc.
#

"""Launch ouster nodes using a composite container"""

from pathlib import Path
import launch
from ament_index_python.packages import get_package_share_directory
from launch_ros.actions import LoadComposableNodes
from launch_ros.descriptions import ComposableNode
from launch.actions import (DeclareLaunchArgument, IncludeLaunchDescription,
                            ExecuteProcess, TimerAction)
from launch.conditions import IfCondition
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, FindExecutable


def generate_launch_description():
    """
    Generate launch description for running ouster_ros components in a single
    process/container.
    """
    catabot_bringup_ros_pkg_dir = get_package_share_directory('catabot_bringup')
    ouster_ros_pkg_dir = get_package_share_directory('ouster_ros')
    default_params_file = \
        Path(catabot_bringup_ros_pkg_dir) / 'param' / 'os_sensor_cloud_image_params.yaml'
    params_file = LaunchConfiguration('params_file')
    params_file_arg = DeclareLaunchArgument('params_file',
                                            default_value=str(
                                                default_params_file),
                                            description='name or path to the parameters file to use.')

    ouster_ns = LaunchConfiguration('ouster_ns')
    ouster_ns_arg = DeclareLaunchArgument(
        'ouster_ns', default_value='ouster')

    rviz_enable = LaunchConfiguration('viz')
    rviz_enable_arg = DeclareLaunchArgument('viz', default_value='True')

    auto_start = LaunchConfiguration('auto_start')
    auto_start_arg = DeclareLaunchArgument('auto_start', default_value='True')

    os_sensor = LoadComposableNodes(
    target_container='shared_container', # namespace/name
    composable_node_descriptions=[
        ComposableNode(
        package='ouster_ros',
        plugin='ouster_ros::OusterSensor',
        name='os_sensor',
        namespace=ouster_ns,
        parameters=[params_file,
        {'auto_start': auto_start}]
        ),
    ],
    )

    os_cloud = LoadComposableNodes(
    target_container='shared_container', # namespace/name
    composable_node_descriptions=[
    ComposableNode(
        package='ouster_ros',
        plugin='ouster_ros::OusterCloud',
        name='os_cloud',
        namespace=ouster_ns,
        parameters=[params_file]
        ),
    ],
    )

    os_image = LoadComposableNodes(
    target_container='shared_container', # namespace/name
    composable_node_descriptions=[
        ComposableNode(
        package='ouster_ros',
        plugin='ouster_ros::OusterImage',
        name='os_image',
        namespace=ouster_ns,
        parameters=[params_file]
        ),
    ],
    )

    rviz_launch_file_path = \
        Path(ouster_ros_pkg_dir) / 'launch' / 'rviz.launch.py'
    rviz_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([str(rviz_launch_file_path)]),
        condition=IfCondition(rviz_enable)
    )

    return launch.LaunchDescription([
        params_file_arg,
        ouster_ns_arg,
        rviz_enable_arg,
        auto_start_arg,
        rviz_launch,
        os_sensor,
        os_cloud,
        os_image
    ])
