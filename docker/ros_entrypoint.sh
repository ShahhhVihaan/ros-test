#!/bin/bash
set -e

# Fix permissions if needed
if [ -d "/home/${USER}/.config" ]; then
    sudo chown -R ${USER}:${USER} /home/${USER}/.config
fi

# Setup ROS environment
source "/opt/ros/${ROS_DISTRO}/setup.bash"

# Source workspace setup if it exists (the if check ensures it doesn't fail if the workspace hasn't been built yet)
if [ -f "${ROS2_WS}/install/setup.bash" ]; then
    source "${ROS2_WS}/install/setup.bash"
fi

# Set RMW implementation for non-interactive processes
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

exec "$@"