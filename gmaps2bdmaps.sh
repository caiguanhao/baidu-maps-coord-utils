#!/bin/bash

set -e

BC=$(which bc)

CURL=$(which curl)

CHAR="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

ARG_1=${1//,/}
ARG_2=$2

if [[ $ARG_1 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]] && 
   [[ $ARG_2 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
then
    COORD_X=$ARG_1
    COORD_Y=$ARG_2
else
    echo "No coordinates specified."
    exit
fi

append_char_to()
{
    RESULT=$(printf "\x$(printf %x ${!3})")
    eval "${1}=\"${!1}\${RESULT}\""
}

decode()
{
    K=0
    B=""
    while [[ $K -lt ${#1} ]]; do
        C=${CHAR%%${1:$K:1}*}
        C=${#C}
        (( K = K + 1 ))
        D=${CHAR%%${1:$K:1}*}
        D=${#D}
        (( K = K + 1 ))
        G=${CHAR%%${1:$K:1}*}
        G=${#G}
        (( K = K + 1 ))
        J=${CHAR%%${1:$K:1}*}
        J=${#J}
        (( K = K + 1 ))
        C=$(( $C << 2 | $D >> 4 ))
        D=$(( ( $D & 15 ) << 4 | $G >> 2 ))
        E=$(( ( $G & 3 ) << 6 | $J ))
        append_char_to B with_char_code C
        if [[ ! $G -eq 64 ]]; then
            append_char_to B with_char_code D
        fi
        if [[ ! $J -eq 64 ]]; then
            append_char_to B with_char_code E
        fi
    done
    eval "${3}=\${B}"
}

QUERY=`$CURL -G -L -s "http://api.map.baidu.com/ag/coord/convert?from=2&to=4&"\
                         --data "x=${COORD_Y}" --data "y=${COORD_X}"`

X=${QUERY%%\"x\"*}
X=$(echo ${QUERY:${#X}} | sed 's/"x":"\([^"]*\)".*/\1/')

Y=${QUERY%%\"y\"*}
Y=$(echo ${QUERY:${#Y}} | sed 's/"y":"\([^"]*\)".*/\1/')

decode $X to OUT
echo -n "$OUT, "

decode $Y to OUT
echo $OUT
