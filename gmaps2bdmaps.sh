#!/bin/bash
# Baidu Maps Coordinates Utils
# https://github.com/caiguanhao/baidu-maps-coord-utils
#
# Baidu's JavaScript:
#
# var cb = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
# function db(a) {
#     var b = "",
#         c, d, e = "",
#         g, j = "",
#         k = 0;
#     g = /[^A-Za-z0-9\+\/\=]/g;
#     if (!a || g.exec(a)) return a;
#     a = a.replace(/[^A-Za-z0-9\+\/\=]/g, "");
#     do {
#         c = cb.indexOf(a.charAt(k++));
#         d = cb.indexOf(a.charAt(k++));
#         g = cb.indexOf(a.charAt(k++));
#         j = cb.indexOf(a.charAt(k++));
#         c = c << 2 | d >> 4, d = (d & 15) << 4 | g >> 2;
#         e = (g & 3) << 6 | j, b += String.fromCharCode(c);
#         64 != g && (b += String.fromCharCode(d));
#         64 != j && (b += String.fromCharCode(e));
#     } while (k < a.length);
#     return b
# }

BC=$(which bc)

if [[ ${#BC} -eq 0 ]]; then
    echo "Install bc first."
    exit 1
fi

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
    RESULT=$(printf "\x$(printf %x ${!3})") # String.fromCharCode()
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

CONVERT="http://api.map.baidu.com/ag/coord/convert"

QUERY=`$DOWNLOAD "${CONVERT}?from=2&to=4&x=${COORD_Y}&y=${COORD_X}"`

X=${QUERY%%\"x\"*}
X=$(echo ${QUERY:${#X}} | sed 's/"x":"\([^"]*\)".*/\1/')

Y=${QUERY%%\"y\"*}
Y=$(echo ${QUERY:${#Y}} | sed 's/"y":"\([^"]*\)".*/\1/')

decode $X to OUT
echo -n "$OUT, "

decode $Y to OUT
echo $OUT
