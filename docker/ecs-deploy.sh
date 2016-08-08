#!/bin/bash

cat << EOT > /tmp/container-definitions.json
{
  "containerDefinitions": [
    {
      "name": "JavaTomcatDefinition",
      "image": "375144106126.dkr.ecr.us-east-1.amazonaws.com/java_tomcat-hello_world:latest",
      "cpu": 1,
      "portMappings": [{
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }],
      "command": [ "/usr/bin/supervisord" ],
      "memory": 256,
      "essential": true
    }
  ],
  "family": "JavaTomcatDefinition"
}
EOT

NEW_TASK=`aws ecs register-task-definition --cli-input-json file:///tmp/container-definitions.json |  jq -r .taskDefinition.taskDefinitionArn`
aws ecs update-service --cluster JavaTomcatCluster --service JavaTomcatService --task-definition ${NEW_TASK} --desired-count 2


# タスクの停止
RUNNING_TASKS=`aws ecs list-tasks --cluster JavaTomcatCluster --service-name JavaTomcatService | jq -r '.taskArns[]'`
aws ecs stop-task --cluster JavaTomcatCluster --task ${RUNNING_TASKS}
