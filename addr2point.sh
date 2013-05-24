#!/bin/bash

CURL=$(which curl)

if [[ ${#@} -gt 0 ]]; then
    ADDRESS=$@
else
    echo "Please provide one address (for example: \"天安门\")."
    exit 1
fi

SEARCH()
{
	SEARCH_RESULT=`$CURL -G -L -s "http://api.map.baidu.com/?qt=gc"\
						 --data-urlencode "wd=${@}"`
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
