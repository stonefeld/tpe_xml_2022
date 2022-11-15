#!/bin/bash

# Agrego las variables del classpath
source shell

# Declarando los nombres de los archivos a utilizar
info_file='season_info.xml'
summaries_file='season_summaries.xml'
data_file='season_data.xml'
extract_data_file='extract_season_data.xq'
generate_md_file='generate_markdown.xsl'
md_file='season_page.md'

# TODO(ts): meter los errores en un xml con error
print_error() {
    [ "$1" ] && echo "ERROR: $1"
    echo "Usage: tpe.sh <season_id>"
    if [ "$1" ]; then
        echo "$1" > "$data_file"
        generate_md
    fi
    exit
}

generate_md() {
    [ -f "$generate_md_file" ] || return
    java net.sf.saxon.Transform -s:"$data_file" -xsl:"$generate_md_file" > "$md_file" 2>/dev/null
}

# Obtengo el id de la season
[ -z "$*" ] && print_error
season_id="$1"

# Verifico que el id sea valido
[ -f seasons.xml ] || print_error "File 'seasons.xml' is required"
grep -E "\s*<season\s+id=\"$season_id\".*/>" seasons.xml 1>/dev/null
[ "$?" -ne 0 ] && print_error "The given 'season_id' is not valid"

# Verifico la existencia de una api key
[ -f api_key.txt ] || { [ -z "$SPORTRADAR_API" ] && print_error "File 'api_key.txt' or envvar 'SPORTRADAR_API' are required"; }
SPORTRADAR_API="$(cat api_key.txt)"

# Declarando las urls para las correspondientes queries
info_url="https://api.sportradar.com/soccer/trial/v4/en/seasons/${season_id}/info.xml?api_key=${SPORTRADAR_API}"
summaries_url="https://api.sportradar.us/soccer/trial/v4/en/seasons/${season_id}/summaries.xml?api_key=${SPORTRADAR_API}"

curl $info_url -o $info_file 2>/dev/null
curl $summaries_url -o $summaries_file 2>/dev/null

sed -i 's%\sxmlns="http://schemas.sportradar.com/sportsapi/soccer/v4"%%' "$info_file"
sed -i 's%\sxmlns="http://schemas.sportradar.com/sportsapi/soccer/v4"%%' "$summaries_file"

java net.sf.saxon.Query "$extract_data_file" > "$data_file"
generate_md
