#!/bin/bash
# Baidu Maps Coordinates Utils
# https://github.com/caiguanhao/baidu-maps-coord-utils

CURL=$(which curl)

if [[ ${#@} -gt 0 ]]; then
    ADDRESS=$@
else
    echo "Please provide one address (for example: \"天安门\")."
    exit 1
fi

SEARCH()
{
	SEARCH_RESULT=`$CURL -G -L -s "http://api.map.baidu.com/?qt=s&rn=1"\
						 --data-urlencode "wd=${@}"`
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
