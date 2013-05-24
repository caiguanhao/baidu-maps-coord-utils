#!/bin/bash
# Baidu Maps Coordinates Utils
# https://github.com/caiguanhao/baidu-maps-coord-utils

set -e

CURL=$(which curl)

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

RESULT=`$CURL -G -L -s "http://api.map.baidu.com/?qt=rgc"\
				--data "x=${POINT_X}"\
				--data "y=${POINT_Y}"`

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
