# Baidu Maps Coordinates Utils

Use these utils to automatically fetch coordinates of large quantities of addresses in China. These coordinates may be used as the default coordinates of the embeded Baidu Maps in web pages. Note that the way how Baidu Maps represent its coordinates is different from the rest of the world.

## One-line command

    $ bash addr2geo.sh 广州塔 | xargs bash geo2point.sh | xargs bash point2coord.sh
      113.332243, 23.111631

## Address to GEO string

Returns the GEO string of the first search result for specified Chinese address in Baidu Maps. If no search results returned, try to remove last character and search again until GEO string is found.

    bash addr2geo.sh 天安门

## GEO string to point

The argument supports GEO string with only one point. For those strings with multiple points, you may either use Baidu's [JavaScript functions](http://api.map.baidu.com/getmodules?v=1.2&mod=scommon) to convert them or split the string by ';' and treat each part as an argument to this script.

Points in multi-point GEO string share the same GEO type, which is determined by the first character of the string. A possible multi-point GEO string may look like this: ``.=LmIPNBjMOxcA;=LmIPNBjMOxcA;`` .

    bash geo2point.sh ".=LmIPNBjMOxcA;"

## Point to coordinates

    bash point2coord.sh 12958130.03, 4826652.51

### Coordinates to point

    bash coord2point.sh 116.403596, 39.920041

## Point to address

Find the possible address to the point.

    bash point2addr.sh 12958130.03, 4826652.51

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

## Examples

* [Bash script to auto convert more than 50 addresses to coordinates](https://github.com/qnn/qnn-agent-sites/blob/master/misc/update_coords.sh)

## Developer

* caiguanhao

## 原理

利用 cURL 访问百度地图公开的 API ，搜索地址，从结果中获取GEO字符串，如果没有结果，会删除最后一个字符，继续搜索，直至有结果为止。百度把地图上点的坐标“加密”成为GEO字符串，点的坐标又要经过运算才可得到经纬坐标。百度表示坐标的方法和正常的表示方法相反。

我在百度上找不到可以直接转换或者获取坐标的方法。

利用这个脚本可以快速获取大批地址对应的坐标，这些坐标可以作为各网站上嵌入的百度地图的默认坐标。
