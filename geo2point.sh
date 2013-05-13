#!/bin/bash

set -e

BC=$(which bc)

if [[ ${#1} -eq 15 ]]; then
    GEO=$1
else
    echo "Please provide one GEO string (15 characters long, for example: \".=LmIPNBjMOxcA;\")."
    exit 1
fi

TYPES=("=" "." "-" "*")

GEOTYPE=-1

if [[ ${GEO:0:1} == ${TYPES[1]} ]]; then
    GEOTYPE=2
else
    if [[ ${GEO:0:1} == ${TYPES[2]} ]]; then
        GEOTYPE=1
    else
        if [[ ${GEO:0:1} == ${TYPES[3]} ]]; then
            GEOTYPE=0
        fi
    fi
fi

#echo ${GEOTYPE}

GEO=${GEO:1}

CHAR_CODE_FROM()
{
    FIRST_CHAR_CODE=$(printf "%d" "'${1:0:1}")
    local RESULT=-1
    if [[ $FIRST_CHAR_CODE -ge $(printf "%d" "'A") ]] &&
       [[ $FIRST_CHAR_CODE -le $(printf "%d" "'Z") ]]
    then
        RESULT=$(( $FIRST_CHAR_CODE - $(printf "%d" "'A") ))
    else
        if [[ $FIRST_CHAR_CODE -ge $(printf "%d" "'a") ]] &&
           [[ $FIRST_CHAR_CODE -le $(printf "%d" "'z") ]]
        then
            RESULT=$(( 26 + $FIRST_CHAR_CODE - $(printf "%d" "'a") ))
        else
            if [[ $FIRST_CHAR_CODE -ge $(printf "%d" "'0") ]] &&
               [[ $FIRST_CHAR_CODE -le $(printf "%d" "'9") ]]
            then
                RESULT=$(( 52 + $FIRST_CHAR_CODE - $(printf "%d" "'0") ))
            else
                if [[ ${1:0:1} == "+" ]]; then
                    RESULT=62
                elif [[ ${1:0:1} == "/" ]]; then
                    RESULT=63
                fi
            fi
        fi
    fi
    eval "${3}=\$RESULT"
}

CONVERT()
{
    local RESULT=0
    local T=0
    local F=0
    for ((C=0; C < 6 ; C++))
    do
        CHAR_CODE_FROM "${1:$(( 1 + $C )):1}" TO E
        if [[ $E -lt 0 ]]; then
            eval "${5}=$(( -1 - $C ))"
            return
        fi
        T=$(( $T + ( $E << ( 6 * $C ) ) ))
        CHAR_CODE_FROM "${1:$(( 7 + $C )):1}" TO E
        if [[ $E -lt 0 ]]; then
            eval "${5}=$(( -7 - $C ))"
            return
        fi
        F=$(( $F + ( $E << ( 6 * $C ) ) ))
    done
    eval "${3}+=(\$T)"
    eval "${3}+=(\$F)"
    eval "${5}=0"
}

K=0
LENGTH=${#GEO}

INT_G=0
ARRAY_L=()

while [[ $K -lt $LENGTH ]]; do
    if [[ ${GEO:$K:1} == ${TYPES[0]} ]]; then
        if [[ $(($LENGTH - $K)) -lt 13 ]]; then
            break
        fi

        CONVERT ${GEO:$K:13} TO ARRAY_L WITH_RETURN_CODE INT_G
        if [[ $INT_G -lt 0 ]]; then
            break
        fi
        (( K = K + 13 ))
    else
        if [[ ${GEO:$K:1} == ";" ]]; then
            ARRAY_L=(
                $(echo "scale=2; ${ARRAY_L[0]} / 100" | $BC )
                $(echo "scale=2; ${ARRAY_L[1]} / 100" | $BC )
            )
            echo "${ARRAY_L[0]}, ${ARRAY_L[1]}"
            exit 0
        else
            break
        fi
    fi
done

exit 1
