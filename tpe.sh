#!/bin/sh

print_error() {
    [ "$1" ] && echo "ERROR: $1"
    echo "Usage: tpe.sh [ARGS]"
    exit
}

[ -z "$*" ] && print_error
season_id="$1"

[ -f api_key.txt ] || print_error "No 'api_key.txt' found"
SPORTRADAR_API="$(cat api_key.txt)"

info_file='season_info.xml'
summaries_file='season_summaries.xml'
info_url="https://api.sportradar.com/soccer/trial/v4/en/seasons/${season_id}/info.xml?api_key=${SPORTRADAR_API}"
summaries_url="https://api.sportradar.us/soccer/trial/v4/en/seasons/${season_id}/summaries.xml?api_key=${SPORTRADAR_API}"

curl $info_url -o $info_file 2>/dev/null
curl $summaries_url -o $summaries_file 2>/dev/null
