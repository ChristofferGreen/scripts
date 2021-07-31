#!/bin/bash
echo "########################################"
ME="$(basename "$0")"
echo "Starting $ME"

sys ()
{
  local NAME=$1
  local START_STOP=$2
  echo "$START_STOP $NAME"
  sudo systemctl $START_STOP $NAME
}

sys radarr  $1
sys lidarr  $1
sys sonarr  $1
sys bazarr  $1
sys deluged $1
