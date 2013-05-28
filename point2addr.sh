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

ARG_1=${1//,/}
ARG_2=$2

if [[ $ARG_1 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]] && 
   [[ $ARG_2 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
then
    POINT_X=$ARG_1
    POINT_Y=$ARG_2
else
    echo "Please provide one point (for example: 12616224.86, 2628601.01)."
    exit 1
fi

API="http://api.map.baidu.com/"

RESULT=`$DOWNLOAD "${API}?qt=rgc&x=${POINT_X}&y=${POINT_Y}"`

if [[ ! $RESULT == *\"content\"* ]]; then
    echo "Address not found."
    exit 1
fi

CONTENT_POS=${RESULT%%\"content\"*}
CONTENT=${RESULT:${#CONTENT_POS}}

ADDRESS_POS=${CONTENT%%\"address\"*}
ADDRESS=$(echo ${CONTENT:${#ADDRESS_POS}} | sed 's/"address":"\([^"]*\)".*/\1/')

if [[ ${#ADDRESS} -eq 0 ]]; then
    echo "Address not found."
    exit 1
else
    echo $ADDRESS
fi
