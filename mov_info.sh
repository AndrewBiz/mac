#!/bin/bash
#the hardcoded location of the AtomicParsley binary
AP_bin="/Applications/AtomicParsley/AtomicParsley"

My_cmd="-t 1"
echo '****************************'
echo $AP_bin "$1" $My_cmd
echo '****************************'
$AP_bin "$1" $My_cmd

My_cmd="--brands"
echo '****************************'
echo $AP_bin "$1" $My_cmd
echo '****************************'
$AP_bin "$1" $My_cmd

My_cmd="-T 1"
echo '****************************'
echo $AP_bin "$1" $My_cmd
echo '****************************'
$AP_bin "$1" $My_cmd
