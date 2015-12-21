#!/bin/bash

# this script expects two variables to be defined:
# DEVICE_LABEL is the label given to the removable storage device
# DESTINATION is the destination folder

if [ -z "$DEVICE_LABEL" ]; then exit 2; fi
if [ -z "$DESTINATION" ]; then exit 2; fi

# shortcuts
SOURCE_BASE="/media/$USER/$DEVICE_LABEL"
SOURCE=$SOURCE_BASE/Data

# exit if it's not the right USB key
if [ ! -d "$SOURCE" ]; then
    exit 2
fi

# copy data from source base to destination
cp -f $SOURCE/*.csv $DESTINATION

# if the task was successful show a badge, if not When enters an error state
if [ "$?" = "0" ]; then
    gvfs-mount -u $SOURCE_BASE
    notify-send -i info "Data Gatherer" "Files successfully transferred, remove device"
else
    exit 2
fi
