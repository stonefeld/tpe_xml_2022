#!/bin/bash

# Agregamos las variables del classpath
source shell

# Declaramos los nombres de los archivos a utilizar
info_file='season_info.xml'
summaries_file='season_summaries.xml'
data_file='season_data.xml'
extract_data_file='extract_season_data.xq'
generate_md_file='generate_markdown.xsl'
md_file='season_page.md'

# Imprime el error por stdout y genera el md pero con mensaje de error
print_error() {
    [ "$1" ] && echo "ERROR: $1"
    echo 'Usage: tpe.sh <season_id>'
    if [ "$1" ]; then
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><season_data xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-Instance\" xsi:noNamespaceSchemaLocation=\"season_data.xsd\"><error>$1</error></season_data>" > "$data_file"
        generate_md
    fi
    exit
}

# Genera el markdown file a partir del 'generate_markdown.xsl'
generate_md() {
    [ -f "$generate_md_file" ] || return
    java net.sf.saxon.Transform -s:"$data_file" -xsl:"$generate_md_file" > "$md_file" 2>/dev/null
}

# Obtenemos el id de la season
[ -z "$*" ] && print_error "'season_id' is required"
season_id="$1"

# Verificamos que el id sea valido
[ -f seasons.xml ] || print_error "File 'seasons.xml' is required"
grep -E "\s*<season\s+id=\"$season_id\".*/>" seasons.xml &>/dev/null
[ "$?" -ne 0 ] && print_error "The given 'season_id' is not valid"

# Verificamos la existencia de una api key
[ -f api_key.txt ] || { [ -z "$SPORTRADAR_API" ] && print_error "File 'api_key.txt' or envvar 'SPORTRADAR_API' are required"; }
SPORTRADAR_API="$(cat api_key.txt)"

# Declaramos las urls para las correspondientes queries
base_url="https://api.sportradar.com/soccer/trial/v4/en/seasons/${season_id}"
info_url="$base_url/info.xml?api_key=${SPORTRADAR_API}"
summaries_url="$base_url/summaries.xml?api_key=${SPORTRADAR_API}"

# Realizamos ambos GET Request para obtener los archivos de info y summaries
curl $info_url -o $info_file 2>/dev/null
curl $summaries_url -o $summaries_file 2>/dev/null
[ "$?" -ne 0 ] && print_error "Couldn't reach 'api.sportradar.com'. Make sure you have a stable internet connection."

# Eliminamos el namespace en cada xml para que las consultas por XQuery funcionen
sed -i 's%\sxmlns="http://schemas.sportradar.com/sportsapi/soccer/v4"%%' "$info_file"
sed -i 's%\sxmlns="http://schemas.sportradar.com/sportsapi/soccer/v4"%%' "$summaries_file"

# Realizamos la consulta por XQuery que generara el archivo 'season_data.xml'
java net.sf.saxon.Query "$extract_data_file" > "$data_file" 2>/dev/null
java dom.Writer -v -s "$data_file" 2>&1 >/dev/null | grep -E '^\[Error\]' &>/dev/null
[ "$?" -eq 0 ] && print_error "'season_data.xml' did not match the requirements on 'season_data.xsd'"
generate_md
