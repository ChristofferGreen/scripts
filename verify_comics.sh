#!/bin/bash
# Dependencies: jpeginfo, pngcheck

usage()
{
  echo "Usage: verify_manga [ -d | --delete ] [ -v | --verbose ] filenames/directories"
  exit 0
}

PARSED_ARGUMENTS=$(getopt -a -n verify_comics -o dv --long delete,verbose -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --delete)  DELETE=1     ; shift   ;;
    -v | --verbose) VERBOSE=1    ; shift   ;;
    --) shift; break ;;
  esac
done

info () { local TEXT=$1
  if (( VERBOSE == 1 )); then
    echo -ne "$TEXT\033[0K\r"
  fi
}

prepare_tmp () {
  mkdir -p /tmp/comic_verify
  cd /tmp/comic_verify
  rm -f *
}

check_return () { local COMMAND="$1"; local CBZ_PATH="$2"; local IMAGE_NAME="$3"
  eval "$COMMAND" &> /dev/null
  local STATUS=$?
  if (( STATUS != 0 )); then
    echo "Broken: " $CBZ_PATH $IMAGE_NAME >&2
    if (( $DELETE == 1 )); then
      echo "Deleting file: $CBZ_PATH"
      rm "$CBZ_PATH"
    fi
  else
    : #echo "ok: " $2
  fi
  return $STATUS
}

handle_cbz () { local CBZ_PATH="$1";
  prepare_tmp
  check_return "unzip \"$CBZ_PATH\"" "$CBZ_PATH" "N/A"
  local STATUS=$?
  if (( $STATUS != 0 )); then
    return $STATUS
  fi
  shopt -s nullglob
  for i in *.{jpg,jpeg}; do check_return "jpeginfo -c \"$i\"" "$CBZ_PATH" "$i"; done
  for i in *.png;        do check_return "pngcheck \"$i\""    "$CBZ_PATH" "$i"; done
}

parse_file () { local COMIC_FILE_PATH="$1"
  info "Checking $COMIC_FILE_PATH"
  if [[ "$COMIC_FILE_PATH" == *.cbz ]]; then handle_cbz "$COMIC_FILE_PATH"; fi
  info "Checked $COMIC_FILE_PATH"
}

parse_dir () { local DIR_PATH=$1
  readarray -d '' FILES < <(find "$DIR_PATH" -name '*.cbz' -print0)
  for i in "${FILES[@]}"; do parse_file "$i"; done
}

main () {
  for IN_PATH in "$@"; do
    if [[ -d "${IN_PATH}" ]]; then
      parse_dir "${IN_PATH}"
    else 
      parse_file "${IN_PATH}"
    fi
  done
  echo ""
}

main "$@"
