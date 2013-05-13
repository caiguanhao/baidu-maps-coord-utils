# Baidu Maps Coordinates Utils

## One-line command

    $ bash addr2geo.sh 广州塔 | xargs bash geo2point.sh | xargs bash point2coord.sh
      113.332243, 23.111631

## Address to GEO string

Returns the GEO string of the first search result for specified Chinese address in Baidu Maps. If no search results returned, try to remove last character and search again until GEO string is found.

    bash addr2geo.sh 天安门

## GEO string to point conversion

The argument supports GEO string with only one point. For those strings with multiple points, you may either use Baidu's [JavaScript functions](http://api.map.baidu.com/getmodules?v=1.2&mod=scommon) to convert them or split the string by ';' and treat each part as an argument to this script.

Points in multi-point GEO string share the same GEO type, which is determined by the first character of the string. A possible multi-point GEO string may look like this: ``.=LmIPNBjMOxcA;=LmIPNBjMOxcA;`` .

    bash geo2point.sh ".=LmIPNBjMOxcA;"

## Point to coordinates conversion

    bash point2coord.sh 12958130.03, 4826652.51

## View / Use Baidu's JavaScript

* Open [http://api.map.baidu.com/lbsapi/getpoint/](http://api.map.baidu.com/lbsapi/getpoint/) in Google Chrome.
* Open Developer Tools panel and select Sources tab.
* Select getscript JS file and open Pretty Print mode.
* Find ``convertMC2LL: function`` and add a breakpoint inside the function by clicking the line number.
  * This is the function to convert point to coordinates.
* Search something in the web page to trigger the script.
* When it reaches to the breakpoint, click O.parseGeo in Call Stack on the right sidebar.
* The script file opened in new tab contains:
  * Functions to convert GEO string to point:
    * You can open the Console and type ``Q(".=LmIPNBjMOxcA;=LmIPNBjMOxcA;")``

## Requirements

* cURL
* bc

## Developer

* caiguanhao
