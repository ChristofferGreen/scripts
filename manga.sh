#!/bin/bash
echo "########################################"
ME="$(basename "$0")"
echo "Starting $ME"

MANGA_PATH="/mnt/media/manga"
ARCHIVE_NAME="archive"
NEW_NAME="new"
LANGUAGE='gb'

function copy_cover() {
  local COVERS_PATH=$1
  local MANGA_PATH=$2
  local MANGA_NAME=$3
  FROM="$COVERS_PATH/$MANGA_NAME"
  TO="$MANGA_PATH/cover"
  echo "From: $FROM To: $TO"
  if [ -e "$FROM.jpg" ]; then
    cp "$FROM.jpg" "$TO.jpg"
  fi
  if [ -e "$FROM.png" ]; then
    cp "$FROM.png" "$TO.jpg"
  fi
}

function link() {
  local FROM=$1
  local TO=$2
  local START=$3
  local AMOUNT=$4

  if [ "$START" == "x" ] && [ "$AMOUNT" == "x" ]; then
    return 0
  fi

  mkdir -p "${TO}"
  local T="10000"
  local H="$AMOUNT"
  if [ $START == "end" ]; then
    T="$AMOUNT"
    H="10000"
  fi
  local FILES=($(ls -1v "${FROM}/"*.cbz | xargs -n1 basename | tail -n $T | head -n $H)) # Array of last Amount from archive dir

  for i in "${FILES[@]}"
  do
    ln -fs "${FROM}/${i}" "${TO}/${i}"
  done
}

function download() {
  local NAME=$1
  local URL=$2
  local START=$3
  local LINK_AMOUNT=$4
  local DOWNLOAD_DIR=$5

  local USER_AGENT='--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0"'
  local COOKIES='--cookies cf_clearance=9ced1dc4068fb9ecf00ef41836eec5e6ea4779b8-1595750924-0-1z876a9225zbb5514c6z30f2590-150 __cfduid=d70b43850ffa05c7a57b7856e15af43de1595750935'
  local ARCHIVE_COMMAND="echo '${LANGUAGE}' | manga-py $URL -d '$DOWNLOAD_DIR/$ARCHIVE_NAME/' -z -n '$NAME' -o '$NAME' --show-current-chapter-info -f -R -N ${USER_AGENT} ${COOKIES}"

  mkdir -p "${DOWNLOAD_DIR}/${ARCHIVE_NAME}/${NAME}/"
  echo -e "\tExecuting: ${ARCHIVE_COMMAND}"
  eval ${ARCHIVE_COMMAND}
  if [ $? -gt 0 ]; then
    ERROR+="Could not download $NAME from $URL\n"
  fi
  link "$DOWNLOAD_DIR/$ARCHIVE_NAME/$NAME" "$DOWNLOAD_DIR/$NEW_NAME/$NAME" $START $LINK_AMOUNT
  #copy_cover "$DOWNLOAD_DIR/covers" "$DOWNLOAD_DIR/$NEW_NAME/$NAME" "$NAME"
}

function grab_mangasee123() {
  local NAME=$1
  local START=$2
  local LINK_AMOUNT=$3
  local ENGLISH_NAME=${4:-$NAME}
  ENGLISH_NAME=${ENGLISH_NAME//-/' '}

  download "$ENGLISH_NAME" "https://mangasee123.com/manga/$NAME" $START $LINK_AMOUNT "$MANGA_PATH"
}

/usr/bin/python3 -m pip install --upgrade pip
/usr/bin/python3 -m pip install manga-py --upgrade

# Grab command,  Url Name,                                                  Start,Amount,English Name
grab_mangasee123 "Akira"                                                    0    20
grab_mangasee123 "Berserk"                                                  0    20
grab_mangasee123 "Bleach"                                                   x    x
grab_mangasee123 "Boruto"                                                   end  20
grab_mangasee123 "Death-Note"                                               0    20
grab_mangasee123 "Fairy-Tail"                                               0    20
grab_mangasee123 "Fairy-Tail-100-Years-Quest"                               0    20 "Fairy Tail 100YQ"
grab_mangasee123 "Gintama"                                                  0    20
grab_mangasee123 "Naruto"                                                   x    x
grab_mangasee123 "Neon-Genesis-Evangelion-Campus-Apocalypse"                0    20 "Neon Genesis Campus"
grab_mangasee123 "Neon-Genesis-Evangelion-The-Shinji-Ikari-Raising-Project" 0    20 "Neon Genesis Raising Shinji"
grab_mangasee123 "Neon-Genesis-Evangelion"                                  0    20
grab_mangasee123 "Onepunch-Man"                                             end  20
grab_mangasee123 "One-Piece"                                                end  40
grab_mangasee123 "Solo-Leveling"                                            0    20
grab_mangasee123 "Slam-Dunk"                                                x    x
grab_mangasee123 "Shingeki-No-Kyojin"                                       x    x "Attack on Titan"

echo "------------"
echo -e "$ERROR" | tr -d '\200-\377' | column -ts# 
echo "------------"
