# Baidu Maps Coordinates Utils

## GEO string to point conversion

The argument supports GEO string with only one point. For those strings with multiple points, you may either use Baidu's [JavaScript functions](http://api.map.baidu.com/getmodules?v=1.2&mod=scommon) to convert them or split the string by ';' and treat each part as an argument to this script.

Points in multi-point GEO string share the same GEO type, which is determined by the first character of the string. A possible multi-point GEO string may look like this: ``.=LmIPNBjMOxcA;=LmIPNBjMOxcA;`` .

    bash geo2point.sh ".=LmIPNBjMOxcA;"

## Point to coordinates conversion

    bash point2coord.sh 12958130.03, 4826652.51

## Developer

* caiguanhao
