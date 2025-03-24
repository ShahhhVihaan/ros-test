ARG BASE_IMAGE=ros:jazzy
FROM $BASE_IMAGE

# Setup a user
ARG UNAME=user
ARG UID=1000
ARG GID=$UID
ARG DEV_ENV=true

# Remove any existing user with the same ID if it exists
RUN if id -u $UID ; then userdel `id -un $UID` ; fi

ENV DEBIAN_FRONTEND=noninteractive

# Create the user with proper sudo access
RUN groupadd --gid $GID $UNAME \
    && useradd --uid $UID --gid $GID -m $UNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $UNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$UNAME \
    && chmod 0440 /etc/sudoers.d/$UNAME

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

# Install development tools if DEV_ENV is true
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
    apt-get install -y --no-install-recommends \
    ros-jazzy-moveit \
    ros-jazzy-ur \
    ros-jazzy-rmw-cyclonedds-cpp \
    ros-jazzy-rviz2 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install dependencies for VNC, NoVNC, and GUI support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    python3-websockify \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install NoVNC and ensure launch.sh is executable
# Install NoVNC and ensure novnc_proxy is executable
RUN wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar xz -C /opt/ && \
    ln -s /opt/noVNC-1.4.0 /opt/novnc && \
    wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.tar.gz | tar xz -C /opt/ && \
    ln -s /opt/websockify-0.11.0 /opt/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html && \
    chmod +x /opt/novnc/utils/novnc_proxy

# Switch to user
USER $UNAME
WORKDIR /home/$UNAME

# Create ROS2 workspace
ENV ROS2_WS=/home/$UNAME/crm_test_ws
RUN mkdir -p ${ROS2_WS}/src

# Setup bash configurations
RUN echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo ". /etc/bash_completion" >> ~/.bashrc && \
    echo "source /usr/share/bash_completion/bash_completion" >> ~/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc && \
    echo "if [ -f ${ROS2_WS}/install/setup.bash ]; then . ${ROS2_WS}/install/setup.bash; fi" >> ~/.bashrc

# Configure VNC (no password for simplicity)
RUN mkdir -p ~/.vnc && \
    touch ~/.vnc/passwd

# Copy and set up the entrypoint script
COPY docker/ros_entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]