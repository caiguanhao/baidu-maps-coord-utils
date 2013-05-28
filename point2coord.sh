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
    POINT_X=$ARG_1
    POINT_Y=$ARG_2
else
    echo "No point specified."
    exit
fi

MCBAND=(
12890594.86             8362377.87                  5591021
3481989.83              1678043.12                  0
)
MC2LL_0=(
1.410526172116255e-8    0.00000898305509648872      -1.9939833816331
200.9824383106796       -187.2403703815547          91.6087516669843
-23.38765649603339      2.57121317296198            -0.03801003308653
17337981.2
)
MC2LL_1=(
-7.435856389565537e-9   0.000008983055097726239     -0.78625201886289
96.32687599759846       -1.85204757529826           -59.36935905485877
47.40033549296737       -16.50741931063887          2.28786674699375
10260144.86
)
MC2LL_2=(
-3.030883460898826e-8   0.00000898305509983578      0.30071316287616
59.74293618442277       7.357984074871              -25.38371002664745
13.45380521110908       -3.29883767235584           0.32710905363475
6856817.37
)
MC2LL_3=(
-1.981981304930552e-8   0.000008983055099779535     0.03278182852591
40.31678527705744       0.65659298677277            -4.44255534477492
0.85341911805263        0.12923347998204            -0.04625736007561
4482777.06
)
MC2LL_4=(
3.09191371068437e-9     0.000008983055096812155     0.00006995724062
23.10934304144901       -0.00023663490511           -0.6321817810242
-0.00663494467273       0.03430082397953            -0.00466043876332
2555164.4
)
MC2LL_5=(
2.890871144776878e-9    0.000008983055095805407     -3.068298e-8
7.47137025468032        -0.00000353937994           -0.02145144861037
-0.00001234426596       0.00010322952773            -0.00000323890364
826088.5
)

calc()
{
    FORMU=$3
    # replace scientific notation
    FORMU=${FORMU//[eE]+/*10^}
    FORMU=${FORMU//[eE]-/*10^-}
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
    RESULT=$(printf %.6f ${!1})
    eval "${1}=\$RESULT"
}

for (( cL=0 ; cL<${#MCBAND[@]} ; cL++ )) ; do
    comp CMP = "${POINT_Y/-/} >= ${MCBAND[$cL]}"
    if [ $CMP -eq 1 ]; then
        MC2LL="MC2LL_$cL[@]"
        M=("${!MC2LL}")

        calc LNG = "${M[0]} + ${M[1]} * ${POINT_X/-/}"
        calc INT = "${POINT_Y/-/} / ${M[9]}"
        calc LAT = "${M[2]} + ${M[3]} * ${INT} ^ 1 + ${M[4]} * ${INT} ^ 2 + \
                              ${M[5]} * ${INT} ^ 3 + ${M[6]} * ${INT} ^ 4 + \
                              ${M[7]} * ${INT} ^ 5 + ${M[8]} * ${INT} ^ 6"

        comp CMP = "${POINT_X} < 0"
        if [ $CMP -eq 1 ]; then
            calc LNG = "${LNG} * -1"
        fi
        comp CMP = "${POINT_Y} < 0"
        if [ $CMP -eq 1 ]; then
            calc LAT = "${LAT} * -1"
        fi

        round LNG
        round LAT

        echo "${LNG}, ${LAT}"
        break
    fi
done

# Baidu's JavaScript:
#
# convertMC2LL: function(cB) {
#     var cC, cE;
#     cC = new b3(Math.abs(cB.lng), Math.abs(cB.lat));
#     for (var cD = 0; cD < this.MCBAND.length; cD++) {
#         if (cC.lat >= this.MCBAND[cD]) {
#             cE = this.MC2LL[cD];
#             break
#         }
#     }
#     var T = this.convertor(cB, cE);
#     var cB = new b3(T.lng.toFixed(6), T.lat.toFixed(6));
#     return cB
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
