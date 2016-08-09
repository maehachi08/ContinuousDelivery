#!/bin/bash

aws ecr get-login --region us-east-1 | sh
docker tag maehachi08/java_servlet_hello_world:latest 375144106126.dkr.ecr.us-east-1.amazonaws.com/java_servlet-hello-world-gocd:latest
docker push 375144106126.dkr.ecr.us-east-1.amazonaws.com/java_servlet-hello-world-gocd:latest
