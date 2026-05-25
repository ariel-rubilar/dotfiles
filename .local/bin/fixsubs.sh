#!/usr/bin/env bash

 if [ ! -f "$1" ]; then
  echo "❌ File not found."
  exit 1
fi

FILE="$1"

show_menu(){
    echo "Subtitle encoding tool"
    echo "Current file: $FILE"
    echo "----------------------"
    echo "1) Detect subtitle encoding"
    echo "2) Fix subtitle encoding for TV"
    echo "3) Exit"
    echo
    read -p "Choose an option (1,2 or 3): " OPTION
    echo
}

read_option() {
    case "$OPTION" in
      1)
        echo "Detecting encoding..."
        if command -v uchardet >/dev/null; then
          uchardet "$FILE"
        else
          file "$FILE"
          echo "(Install 'uchardet' for better detection)"
        fi
        ;;
      2)
        TMP="$(mktemp)"

        echo "Fixing encoding (TV-safe)..."
        iconv -f WINDOWS-1252 -t ISO-8859-1//IGNORE "$FILE" > "$TMP" || {
          echo "❌ Encoding conversion failed."
          rm -f "$TMP"
          exit 1
        }

        mv "$TMP" "$FILE"
        echo "Subtitle encoding fixed."
        ;;
      3)
        exit 0
        ;;
      *)
        echo "❌ Invalid option."
        exit 1
        ;;
    esac
}

while true
do
  show_menu
  read_option
done
