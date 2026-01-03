#!/usr/bin/env python3
"""
Launches the LD06 LiDAR node with parameters loaded from YAML configuration.

This launch file loads all LiDAR parameters from config/ldlidar.yaml,
eliminating hardcoded values and enabling easy reconfiguration.
"""

from launch import LaunchDescription
from launch.substitutions import PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    # Load parameters from YAML file
    config_file = PathJoinSubstitution(
        [FindPackageShare("ldlidar_ros2"), "config", "ldlidar.yaml"]
    )

    # LDROBOT LiDAR publisher node
    ldlidar_node = Node(
        package='ldlidar_ros2',
        executable='ldlidar_ros2_node',
        name='ldlidar_publisher_ld06',
        output='screen',
        parameters=[config_file]
    )

    # base_link to laser_link tf node
    base_link_to_laser_tf_node = Node(
        package='tf2_ros',
        executable='static_transform_publisher',
        name='base_link_to_laser_ld06',
        arguments=['0', '0', '0.18', '0', '0', '0', 'base_link', 'laser_link']
    )

    return LaunchDescription([
        ldlidar_node,
        base_link_to_laser_tf_node,
    ])
