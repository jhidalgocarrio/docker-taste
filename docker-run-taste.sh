#!/bin/bash

docker run -ti -P -v /dev/dri:/dev/dri:rw -v /tmp/.X11-unix:/tmp/.X11-unix -v /dev/tty*:/dev/tty* -u taste -w /home/taste --name taste_container -e DSUPPORT=1 $2 exoter/taste:14.04
