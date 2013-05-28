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
    SEARCH_RESULT=`$DOWNLOAD "http://api.map.baidu.com/?qt=gc&wd=${QUERY}"`
}

SEARCH $ADDRESS

if [[ $SEARCH_RESULT == *\"content\"* ]]; then

    CONTENT_POS=${SEARCH_RESULT%%\"content\"*}
    CONTENT=${SEARCH_RESULT:${#CONTENT_POS}}

    X=${CONTENT%%\"x\"*}
    X=$(echo ${CONTENT:${#X}} | sed 's/"x":"\([^"]*\)".*/\1/')

    Y=${CONTENT%%\"y\"*}
    Y=$(echo ${CONTENT:${#Y}} | sed 's/"y":"\([^"]*\)".*/\1/')

    echo $X, $Y

fi
