#!/bin/bash
# Baidu Maps Coordinates Utils
# https://github.com/caiguanhao/baidu-maps-coord-utils

BC=$(which bc)

if [[ ${#BC} -eq 0 ]]; then
    echo "Install bc first."
    exit 1
fi

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

LLBAND=(
75                      60                          45
30                      15                          0
)
LL2MC_0=(
-0.0015702102444        111320.7020616939           1704480524535203
-10338987376042340      26112667856603880           -35149669176653700
26595700718403920       -10725012454188240          1800819912950474
82.5
)
LL2MC_1=(
0.0008277824516172526   111320.7020463578           647795574.6671607
-4082003173.641316      10774905663.51142           -15171875531.51559
12053065338.62167       -5124939663.577472          913311935.9512032
67.5
)
LL2MC_2=(
0.00337398766765        111320.7020202162           4481351.045890365
-23393751.19931662      79682215.47186455           -115964993.2797253
97236711.15602145       -43661946.33752821          8477230.501135234
52.5
)
LL2MC_3=(
0.00220636496208        111320.7020209128           51751.86112841131
3796837.749470245       992013.7397791013           -1221952.21711287
1340652.697009075       -620943.6990984312          144416.9293806241
37.5
)
LL2MC_4=(
-0.0003441963504368392  111320.7020576856           278.2353980772752
2485758.690035394       6070.750963243378           54821.18345352118
9540.606633304236       -2710.55326746645           1405.483844121726
22.5
)
LL2MC_5=(
-0.0003218135878613132  111320.7020701615           0.00369383431289
823725.6402795718       0.46104986909093            2351.343141331292
1.58060784298199        8.77738589078284            0.37238884252424
7.45
)

calc()
{
    FORMU=$3
    RESULT=$(echo "scale=30; ${FORMU}" | $BC)
    eval "${1}=\$RESULT"
}

comp()
{
    RESULT=$($BC <<< "$3")
    eval "${1}=\$RESULT"
}

round()
{
    RESULT=$(printf %.2f ${!1})
    eval "${1}=\$RESULT"
}

M=()

for (( cL=0 ; cL<${#LLBAND[@]} ; cL++ )) ; do
    comp CMP = "${COORD_Y} >= ${LLBAND[$cL]}"
    if [ $CMP -eq 1 ]; then
        LL2MC="LL2MC_$cL[@]"
        M=("${!LL2MC}")
        break
    fi
done

if [[ ${#M} -eq 0 ]]; then
    for (( cL=${#LLBAND[@]}-1 ; cL>=0 ; cL-- )) ; do
        comp CMP = "${COORD_Y} <= -${LLBAND[$cL]}"
        if [ $CMP -eq 1 ]; then
            LL2MC="LL2MC_$cL[@]"
            M=("${!LL2MC}")
            break
        fi
    done
fi

calc LNG = "${M[0]} + ${M[1]} * ${COORD_X/-/}"
calc INT = "${COORD_Y/-/} / ${M[9]}"
calc LAT = "${M[2]} + ${M[3]} * ${INT} ^ 1 + ${M[4]} * ${INT} ^ 2 + \
                      ${M[5]} * ${INT} ^ 3 + ${M[6]} * ${INT} ^ 4 + \
                      ${M[7]} * ${INT} ^ 5 + ${M[8]} * ${INT} ^ 6"

comp CMP = "${COORD_X} < 0"
if [ $CMP -eq 1 ]; then
    calc LNG = "${LNG} * -1"
fi
comp CMP = "${COORD_Y} < 0"
if [ $CMP -eq 1 ]; then
    calc LAT = "${LAT} * -1"
fi

round LNG
round LAT

echo "${LNG}, ${LAT}"

# Baidu's JavaScript: 
#
# convertLL2MC: function(T) {
#     var cB, cD;
#     T.lng = this.getLoop(T.lng, -180, 180);
#     T.lat = this.getRange(T.lat, -74, 74);
#     cB = new b3(T.lng, T.lat);
#     for (var cC = 0; cC < this.LLBAND.length; cC++) {
#         if (cB.lat >= this.LLBAND[cC]) {
#             cD = this.LL2MC[cC];
#             break
#         }
#     }
#     if (!cD) {
#         for (var cC = this.LLBAND.length - 1; cC >= 0; cC--) {
#             if (cB.lat <= -this.LLBAND[cC]) {
#                 cD = this.LL2MC[cC];
#                 break
#             }
#         }
#     }
#     var cE = this.convertor(T, cD);
#     var T = new b3(cE.lng.toFixed(2), cE.lat.toFixed(2));
#     return T
# }
# convertor: function(cC, cD) {
#     if (!cC || !cD) {
#         return
#     }
#     var T = cD[0] + cD[1] * Math.abs(cC.lng);
#     var cB = Math.abs(cC.lat) / cD[9];
#     var cE = cD[2] + cD[3] * cB + cD[4] * cB * cB + 
#     cD[5] * cB * cB * cB + cD[6] * cB * cB * cB * cB + 
#     cD[7] * cB * cB * cB * cB * cB + cD[8] * cB * cB * cB * cB * cB * cB;
#     T *= (cC.lng < 0 ? -1 : 1);
#     cE *= (cC.lat < 0 ? -1 : 1);
#     return new b3(T, cE)
# }
