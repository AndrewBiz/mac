#!/bin/bash
echo "******************************"
echo "Script using HandBrake ANB (c)"
echo "******************************"
E_NOARGS=65
app="/Applications/video/HandBrakeCLI"
#outdir="/Volumes/WD/temp"
outdir="/temp_vid"
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
  echo "Usage: `basename $0` video_file_name outdir audio_stream sbtl_lang"
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
if [ -z "$3" ]
then
  echo "Usage: `basename $0` video_file_name outdir audio_stream sbtl_lang"
  exit $E_NOARGS;
else
	audiostream=$3
fi
#srtlang1
if [ -z "$4" ]
then
  echo "Usage: `basename $0` video_file_name outdir audio_stream sbtl_lang"
  exit $E_NOARGS;
else
	srtlang1=$4
	subtitle_name1=$base.$srtlang1.srt
fi

$app -i "$video_name" --no-dvdnav -t 1 -c 1 -o "$output_video_name" -f mp4 -w 480 -e x264 -b 500 -a $audiostream -E faac -6 dpl2 -R Auto -B 96 -D 0.0 --srt-file "$subtitle_name1" --srt-codeset UTF-8 --srt-offset 0 --srt-lang $srtlang1 -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subq=6:8x8dct=0:trellis=0