"""Bringup entrypoint.

Select mode with use_composable:=false|true.
"""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    use_composable = LaunchConfiguration("use_composable")

    return LaunchDescription([
        DeclareLaunchArgument("use_composable", default_value="false"),
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource([
                PathJoinSubstitution([
                    FindPackageShare("catabot_bringup"),
                    "launch",
                    "catabot_bringup_common.launch.py",
                ])
            ]),
            launch_arguments={"use_composable": use_composable}.items(),
        )
    ])
