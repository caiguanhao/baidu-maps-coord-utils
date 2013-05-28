#!/bin/bash
# Baidu Maps Coordinates Utils
# https://github.com/caiguanhao/baidu-maps-coord-utils

WGET=$(which wget)
CURL=$(which curl)
if [[ ${#WGET} -eq 0 ]]; then
    if [[ ${#CURL} -eq 0 ]]; then
        echo "Install wget or curl first."
        exit 1
    else
        DOWNLOAD="$CURL -G -L -s"
    fi
else
    DOWNLOAD="$WGET --quiet -O -"
fi

if [[ ${#@} -gt 0 ]]; then
    ADDRESS=$(echo -e "$@")  # support hex code
else
    echo "Please provide one address (for example: \"广州塔\")."
    exit 1
fi

SEARCH()
{
    QUERY="$@"
    QUERY=${QUERY// /+}
    SEARCH_RESULT=`$DOWNLOAD "http://api.map.baidu.com/?qt=s&rn=1&wd=${QUERY}"`
}

SEARCH $ADDRESS

while [[ ! $SEARCH_RESULT == *\"content\"* ]] && [[ ${#ADDRESS} -gt 1 ]]; do
    ADDRESS=${ADDRESS%?}
    SEARCH $ADDRESS
done

CONTENT_POS=${SEARCH_RESULT%%\"content\"*}
CONTENT=${SEARCH_RESULT:${#CONTENT_POS}}

FIRST_GEO_POS=${CONTENT%%\"geo\"*}
FIRST_GEO=$(echo ${CONTENT:${#FIRST_GEO_POS}} | sed 's/"geo":"\([^"]*\)".*/\1/')

echo $FIRST_GEO
