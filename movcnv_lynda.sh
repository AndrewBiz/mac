#!/bin/bash
echo "******************************"
echo "Script using HandBrake ANB (c)"
echo "******************************"
E_NOARGS=65
app="/Applications/HandBrakeCLI"

# check args
if [ -z "$2" ] 
then
	outdir="/temp_vid"
else
	outdir=$2
fi
# input file name
if [ -z "$1" ] 
then
  echo "Usage: `basename $0` video_file_name outdir"
  exit $E_NOARGS;
else
	fullpath=$1
	video_name=$1
	# got from: http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
	filename="${fullpath##*/}"	#Strip longest match of */ from start
	dir="${fullpath:0:${#fullpath} - ${#filename}}" # Substring from 0 thru pos of filename
	base="${filename%.[^.]*}"	# Strip shortest match of . plus at least one non-dot char from end
	ext="${filename:${#base} + 1}"	# Substring from len of base thru end
	if [[ -z "$base" && -n "$ext" ]]; then # If we have an extension and no base, it's really the base
		base=".$ext"
	  ext=""
	fi
	output_video_name=$outdir/$base.m4v
fi
#audiostream
audiostream=1

$app -i "$video_name" -t 1 -c 1 -o "$output_video_name" -f mp4 -w 640 -e x264 -b 100 -a $audiostream -E faac -6 mono -R Auto -B 56 -D 0.0 -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subq=6:8x8dct=0:trellis=0