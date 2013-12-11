#!/bin/bash

TEST()
{
  echo -e "\x1B[37m>" $BASH "$@""\x1B[39m"
  $BASH "$@"
  if [ $? -eq 0 ]; then
    echo -e "\x1B[92mTest of $1 was passed.\x1B[39m"
    echo
  else
    echo -e "\x1B[91mTest of $1 was failed.\x1B[39m"
    exit 1
  fi
}

TEST addr2geo.sh \\xE5\\xB9\\xBF\\xE5\\xB7\\x9E\\xE5\\xA1\\x94
TEST addr2point.sh \\xE5\\xB9\\xBF\\xE5\\xB7\\x9E\\xE5\\xA1\\x94
TEST geo2point.sh ".=UOqMLBsMwqPA;"
TEST point2coord.sh 12616098.76, 2628657.08
TEST coord2point.sh 113.331110, 23.112097
TEST point2addr.sh 12616098.76, 2628657.08
TEST gmaps2bdmaps.sh 23.10641, 113.32449

echo -e "\x1B[92mAll tests were passed.\x1B[39m"
exit 0
