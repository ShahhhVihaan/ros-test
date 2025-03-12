# ros-test
Setting up github actions for ROS2 colcon testing

docker compose -f docker/docker-compose.yaml build crm_test
docker compose -f docker/docker-compose.yaml run --rm crm_test bash