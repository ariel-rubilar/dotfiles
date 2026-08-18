#!/usr/bin/env bash
set -euo pipefail

COUNT=1
LEVEL=""
MODE="sentence"

usage() {
  echo "Usage: kotoba.sh [OPTIONS]"
  echo ""
  echo "Random Japanese phrases and words for learning."
  echo ""
  echo "Options:"
  echo "  -c, --count N     Number of items to show (default: 1)"
  echo "  -w, --words       Word mode (JLPT vocabulary) instead of sentences"
  echo "  -l, --level N     JLPT level 1-5 (only with --words)"
  echo "  -h, --help        Show this help"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--count)
      COUNT="${2:-}"
      [[ -n "$COUNT" ]] || { echo "Error: --count requires a number"; exit 1; }
      shift 2
      ;;
    -w|--words)
      MODE="word"
      shift
      ;;
    -l|--level)
      LEVEL="${2:-}"
      [[ -n "$LEVEL" ]] || { echo "Error: --level requires a number (1-5)"; exit 1; }
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is required"; exit 1; }
done

BOLD=$'\033[1m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
MAGENTA=$'\033[35m'
WHITE=$'\033[97m'
RESET=$'\033[0m'

strip_ansi() {
  echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

display_width() {
  local stripped
  stripped=$(strip_ansi "$1")
  local width=0
  local i char code
  for ((i=0; i<${#stripped}; i++)); do
    char="${stripped:$i:1}"
    printf -v code '%d' "'$char" 2>/dev/null || code=0
    if (( code >= 0x4E00 && code <= 0x9FFF )) || \
       (( code >= 0x3000 && code <= 0x303F )) || \
       (( code >= 0xFF00 && code <= 0xFFEF )) || \
       (( code >= 0x3040 && code <= 0x309F )) || \
       (( code >= 0x30A0 && code <= 0x30FF )); then
      width=$((width + 2))
    else
      width=$((width + 1))
    fi
  done
  echo "$width"
}

CARD_WIDTH=60

draw_line() {
  local left="$1" right="$2"
  local border
  border=$(printf '%0.s─' $(seq 1 $((CARD_WIDTH - 2))))
  printf "${DIM}%s%s%s${RESET}\n" "$left" "$border" "$right"
}

draw_centered() {
  local text="$1"
  local len
  len=$(display_width "$text")
  local inner=$((CARD_WIDTH - 2))
  local padding=$(( (inner - len) / 2 ))
  local pad_right=$(( inner - len - padding ))
  [[ $padding -lt 0 ]] && padding=0
  [[ $pad_right -lt 0 ]] && pad_right=0
  printf "${DIM}│${RESET}%*s%s%*s${DIM}│${RESET}\n" \
    $((padding + 1)) "" "$text" $((pad_right + 1)) ""
}

draw_line_content() {
  local left="$1" right="$2"
  local left_w right_w
  left_w=$(display_width "$left")
  right_w=$(display_width "$right")
  local inner=$((CARD_WIDTH - 2))
  local total=$((left_w + right_w + 4))
  local padding=$(( inner - total ))
  [[ $padding -lt 1 ]] && padding=1
  printf "${DIM}│${RESET}  %s%*s%s  ${DIM}│${RESET}\n" \
    "$left" "$padding" "" "$right"
}

fetch_tatoeba() {
  local count="$1"
  curl -sf "https://api.tatoeba.org/v1/sentences?lang=jpn&sort=random&limit=$count" 2>/dev/null
}

fetch_jlpt() {
  local count="$1"
  local level="$2"
  local offset=$((RANDOM % 8300))
  local url="https://jlpt-vocab-api.vercel.app/api/words?limit=$count&offset=$offset"
  [[ -n "$level" ]] && url="${url}&level=$level"
  curl -sf "$url" 2>/dev/null
}

print_card_header() {
  echo
  draw_line "┌" "┐"
  draw_centered "${MAGENTA}${BOLD}言葉 kotoba${RESET}"
  draw_line "├" "┤"
}

print_card_footer() {
  draw_line "└" "┘"
  echo
}

print_sentences() {
  local json="$1"
  local count
  count=$(echo "$json" | jq '.data | length')
  print_card_header
  for ((i=0; i<count; i++)); do
    local text
    text=$(echo "$json" | jq -r ".data[$i].text")
    [[ $i -gt 0 ]] && draw_line "├" "┤"
    draw_centered "${WHITE}${BOLD}${text}${RESET}"
  done
  print_card_footer
}

print_words() {
  local json="$1"
  local count
  count=$(echo "$json" | jq '.words | length')
  print_card_header
  for ((i=0; i<count; i++)); do
    local word furigana meaning level
    word=$(echo "$json" | jq -r ".words[$i].word")
    furigana=$(echo "$json" | jq -r ".words[$i].furigana")
    meaning=$(echo "$json" | jq -r ".words[$i].meaning")
    level=$(echo "$json" | jq -r ".words[$i].level")
    [[ $i -gt 0 ]] && draw_line "├" "┤"
    local reading=""
    [[ -n "$furigana" ]] && reading=" ${CYAN}(${furigana})${RESET}"
    draw_centered "${WHITE}${BOLD}${word}${RESET}${reading}"
    draw_line_content "${GREEN}${meaning}${RESET}" "${YELLOW}[N${level}]${RESET}"
  done
  print_card_footer
}

main() {
  if [[ "$MODE" == "sentence" ]]; then
    local json
    json=$(fetch_tatoeba "$COUNT") || {
      echo "Tatoeba API unavailable, falling back to JLPT words..."
      MODE="word"
      json=$(fetch_jlpt "$COUNT" "$LEVEL") || { echo "Error: all APIs unavailable"; exit 1; }
      print_words "$json"
      return
    }
    print_sentences "$json"
  else
    local json
    json=$(fetch_jlpt "$COUNT" "$LEVEL") || { echo "Error: JLPT API unavailable"; exit 1; }
    print_words "$json"
  fi
}

main
