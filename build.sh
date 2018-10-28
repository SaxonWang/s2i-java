#!/usr/bin/env bash

docker build -t docker.vpclub.cn/hidevopsio/hinode-java-jar:1.14 .

docker login -p $(oc whoami -t) -u unused docker-registry-default.app.vpclub.io

docker push docker.vpclub.cn/hidevopsio/hinode-java-jar:1.14

