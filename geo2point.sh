#!/bin/bash
# Baidu Maps Coordinates Utils
# https://github.com/caiguanhao/baidu-maps-coord-utils

BC=$(which bc)

if [[ ${#BC} -eq 0 ]]; then
    echo "Install bc first."
    exit 1
fi

set -- ${1//\\\//\/} ${@:2}      # replace \/ to /

if [[ ${#1} -eq 15 ]]; then
    GEO=$1
else
    echo "Please provide one GEO string (15 characters long, for example:"\
         "\".=LmIPNBjMOxcA;\")."
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

# Baidu's JavaScript:
#
# var aK = 0;
# var bo = 1;
# var aF = 2;
# var at = ["=", ".", "-", "*"];
# parseGeo = function (cF, cI) {
#     if (typeof cF != "string" || !cF) {
#         return
#     }
#     var cK = cF.split("|");
#     var T;
#     var cD;
#     var cB;
#     if (cK.length == 1) {
#         T = Q(cF)
#     } else {
#         T = Q(cK[2]);
#         cD = Q(cK[0]);
#         cB = Q(cK[1])
#     }
#     var cG = {
#         type: T.geoType
#     };
#     if (cI) {
#         switch (cG.type) {
#         case aF:
#             var cH = new b3(T.geo[0][0], T.geo[0][1]);
#             var cJ = a2.convertMC2LL(cH);
#             cG.point = cJ;
#             cG.points = [cJ];
#             break;
#         case bo:
#             cG.points = [];
#             var cL = T.geo[0];
#             for (var cE = 0, cC = cL.length - 1; cE < cC; cE += 2) {
#                 var cM = new b3(cL[cE], cL[cE + 1]);
#                 cM = a2.convertMC2LL(cM);
#                 cG.points.push(cM)
#             }
#             cD = new b3(cD.geo[0][0], cD.geo[0][1]);
#             cB = new b3(cB.geo[0][0], cB.geo[0][1]);
#             cD = a2.convertMC2LL(cD);
#             cB = a2.convertMC2LL(cB);
#             cG.bounds = new bE(cD, cB);
#             break;
#         default:
#             break
#         }
#     }
#     return cG
# };
# function Q(cI) {
#     var cH = aj(cI.charAt(0));
#     var cB = cI.substr(1);
#     var cK = 0;
#     var T = cB.length;
#     var cL = [];
#     var cF = [];
#     var cG = [];
#     while (cK < T) {
#         if (cB.charAt(cK) == at[0]) {
#             if ((T - cK) < 13) {
#                 return 0
#             }
#             cG = cr(cB.substr(cK, 13), cL);
#             if (cG < 0) {
#                 return 0
#             }
#             cK += 13
#         } else {
#             if (cB.charAt(cK) == ";") {
#                 cF.push(cL.slice(0));
#                 cL.length = 0;
#                 ++cK
#             } else {
#                 if ((T - cK) < 8) {
#                     return 0
#                 }
#                 cG = aL(cB.substr(cK, 8), cL);
#                 if (cG < 0) {
#                     return 0
#                 }
#                 cK += 8
#             }
#         }
#     }
#     for (var cE = 0, cC = cF.length; cE < cC; cE++) {
#         for (var cD = 0, cJ = cF[cE].length; cD < cJ; cD++) {
#             cF[cE][cD] /= 100
#         }
#     }
#     return {
#         geoType: cH,
#         geo: cF
#     }
# }
# function aj(cB) {
#     var T = -1;
#     if (cB == at[1]) {
#         T = aF
#     } else {
#         if (cB == at[2]) {
#             T = bo
#         } else {
#             if (cB == at[3]) {
#                 T = aK
#             }
#         }
#     }
#     return T
# }
# function cr(cD, cB) {
#     var T = 0;
#     var cF = 0;
#     var cE = 0;
#     for (var cC = 0; cC < 6; cC++) {
#         cE = X(cD.substr(1 + cC, 1));
#         if (cE < 0) {
#             return -1 - cC
#         }
#         T += cE << (6 * cC);
#         cE = X(cD.substr(7 + cC, 1));
#         if (cE < 0) {
#             return -7 - cC
#         }
#         cF += cE << (6 * cC)
#     }
#     cB.push(T);
#     cB.push(cF);
#     return 0
# }
# function X(cB) {
#     var T = cB.charCodeAt(0);
#     if (cB >= "A" && cB <= "Z") {
#         return T - "A".charCodeAt(0)
#     } else {
#         if (cB >= "a" && cB <= "z") {
#             return (26 + T - "a".charCodeAt(0))
#         } else {
#             if (cB >= "0" && cB <= "9") {
#                 return (52 + T - "0".charCodeAt(0))
#             } else {
#                 if (cB == "+") {
#                     return 62
#                 } else {
#                     if (cB == "/") {
#                         return 63
#                     }
#                 }
#             }
#         }
#     }
#     return -1
# }
