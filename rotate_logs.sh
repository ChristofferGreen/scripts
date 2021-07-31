#!/bin/bash
echo "########################################"
SCRIPT_NAME="$(basename "$0")"
echo "Starting $SCRIPT_NAME for user: $USER"

FOLDER_YEAR=20$(date +%y)
FOLDER_MONTH=$(date +%m)
FOLDER_DAY=$(date +%d)
LOGS_PATH=/opt/logs
FOLDER_PATH=$LOGS_PATH/$FOLDER_YEAR/$FOLDER_MONTH/$FOLDER_DAY
LOGFILE=${USER}_nightly.txt
LOGFILE_PATH=$LOGS_PATH/${LOGFILE}

mkdir -p $FOLDER_PATH
if [ "$USER" = "root" ]; then
	echo "Running as root, changing permission of folders."
	chmod 755 -R $LOGS_PATH/$FOLDER_YEAR
	chmod -R u+rwX,go+rX,go-w $LOGS_PATH/$FOLDER_YEAR
	chown -R pi:media $LOGS_PATH/$FOLDER_YEAR
fi

if [ -e ${LOGFILE_PATH} ]; then
	echo "Rotating ${LOGFILE_PATH} to $FOLDER_PATH"
	mv ${LOGFILE_PATH} $FOLDER_PATH
else
	echo "Warning! Could not find $LOGFILE_PATH to rotate into $FOLDER_PATH!"
fi
echo "Finished rotating files"
