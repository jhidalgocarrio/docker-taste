#!/bin/bash

# Script to create container from image
# run docker-run-taste.sh -h <machine_name>

docker run -ti -P \
    --privileged \
    -v /dev/dri:/dev/dri:rw -v /tmp/.X11-unix:/tmp/.X11-unix -v /dev/ttyUSB0:/dev/ttyUSB0:rw \
    -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -v /etc/shadow:/etc/shadow:ro \
    -v ~/.ssh:/home/taste/.ssh -v /dev/video0:/dev/video0:rw -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro -v $1:/home/taste/sargon -u taste -w /home/taste \
    -v /usr/lib/nvidia-340-updates:/usr/lib/nvidia-340-updates \
    --name taste_container \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" -e DSUPPORT=1 $2 exoter/taste:14.04
