#!/bin/bash
echo "########################################"
SCRIPT_NAME="$(basename "$0")"
echo "Starting $SCRIPT_NAME for user: $USER"

function check(){
	MEDIA_PATH=$1
	MEDIA_TYPE=$2
	echo "Checking $MEDIA_PATH for new $MEDIA_TYPE"
	FOUND=$(find $MEDIA_PATH -mmin -1350 -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.avi' -o -iname '*.cbz' -o -iname '*.cbr' \) -printf "%f\n")
	if [ -n "$FOUND" ]
	then
		NEW_MEDIA+="\nNew $MEDIA_TYPE found:\n#################\n${FOUND}"
	fi
}

check "/mnt/chronicles/tv"               "TV shows"
check "/mnt/media/movies"                "Movies"
check "/mnt/media/manga/new"             "Comics/Manga"
check "/mnt/backup/onedrive/Music/Genre" "Music"

if [ -n "$NEW_MEDIA" ]
then
	printf "$NEW_MEDIA \n"
	echo -e "Subject: New Media! $(date)\n\n$NEW_MEDIA" | sendmail christoffer.green@gmail.com
fi
