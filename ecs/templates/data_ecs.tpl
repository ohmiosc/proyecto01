#!/bin/bash

stop ecs
yum -y update && yum -y install vim telnet 
yum update -y ecs-init

echo "ECS_CLUSTER=${ecs_name}" >> /etc/ecs/ecs.config
echo "AWS_DEFAULT_REGION=${region}" >> /etc/ecs/ecs.config
echo "ECS_NUM_IMAGES_DELETE_PER_CYCLE=3" >> /etc/ecs/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=1m" >> /etc/ecs/ecs.config
echo "ECS_CHECKPOINT=false" >> /etc/ecs/ecs.config

service docker restart && start ecs