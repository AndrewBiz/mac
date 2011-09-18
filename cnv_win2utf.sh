#!/bin/bash

# check args
# input file name
if [ -z "$1" ] 
then
  echo "Usage: `basename $0` sourcefile targetfile"
  exit $E_NOARGS;
fi

# output file name
if [ -z "$2" ] 
then
  echo "Usage: `basename $0` sourcefile targetfile"
  exit $E_NOARGS;
fi
iconv -f CP1251 -t UTF-8 $1 > $2