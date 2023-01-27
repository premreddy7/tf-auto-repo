#!/bin/bash
obj=${1}
key=`echo ${2} | tr '/' '.'`

echo "json data"
jq '.' ${obj}


echo "======================"
echo "Value :"
jq ".${key}" ${obj}


# ./object.sh input.json batters/batter[3]/type
