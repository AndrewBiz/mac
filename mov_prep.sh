#!/bin/bash
mov_getpic.sh $1
echo "========================"
AP_bin="/Applications/AtomicParsley/AtomicParsley"
My_cmd="-t"
echo '****************************'
echo $AP_bin "$1" $My_cmd
echo '****************************'
$AP_bin "$1" $My_cmd
