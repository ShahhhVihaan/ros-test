ARG BASE_IMAGE=ros:jazzy
FROM $BASE_IMAGE

# Setup a user
ARG UNAME=user
ARG UID=1000
ARG GID=$UID

# Set DEV_ENV to true by default (for local development)
ARG DEV_ENV=true

# Remove any existing user with the same ID if it exists
RUN if id -u $UID ; then userdel `id -un $UID` ; fi

# Prevent interactive messages in apt install
ENV DEBIAN_FRONTEND=noninteractive

# Create the user with proper sudo access
RUN groupadd --gid $GID $UNAME \
    && useradd --uid $UID --gid $GID -m $UNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $UNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$UNAME \
    && chmod 0440 /etc/sudoers.d/$UNAME

# Make default shell in Dockerfile bash instead of sh
SHELL ["/bin/bash", "-c"]

# Install essential dependencies (always needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgmock-dev \
    apt-utils \
    ccache \
    clang \
    cmake \
    lld \
    llvm \
    libglfw3-dev \
    python3-colcon-mixin \
    python3-colcon-common-extensions \
    python3-colcon-lcov-result \
    python3-colcon-coveragepy-result \
    python3-pip \
    python3-rosdep \
    python3-vcstool \
    wget \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

    # Conditionally install development tools only if DEV_ENV is true
    RUN if [ "$DEV_ENV" = "true" ]; then \
        apt-get update && \
        apt-get install -y --no-install-recommends \
        git \
        nano \
        htop \
        bash-completion \
        vim \
        && apt-get clean && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# Install CRM-specific ROS packages
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
    ros-jazzy-moveit \
    ros-jazzy-ur \
    ros-jazzy-rmw-cyclonedds-cpp \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Now switch to the user
USER $UNAME
WORKDIR /home/$UNAME

# Create a custom workspace
ENV ROS2_WS=/home/$UNAME/crm_test_ws
RUN mkdir -p ${ROS2_WS}/src

# Setup bash configurations - these are just for interactive use
RUN echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo ". /etc/bash_completion" >> ~/.bashrc && \
    echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc && \
    echo "if [ -f ${ROS2_WS}/install/setup.bash ]; then . ${ROS2_WS}/install/setup.bash; fi" >> ~/.bashrc

# Copy and set up the entrypoint script
COPY docker/ros_entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]