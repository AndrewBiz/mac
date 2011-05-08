#!/usr/bin/env bash
if [ -z "$1" ] 
then
	# no args
	pic_to_find='Жопа';
else 	
	pic_to_find=$1
fi
open /Applications/Firefox.app "http://www.google.com/images?as_q=$pic_to_find&hl=ru&output=search&tbm=isch&btnG=%D0%9F%D0%BE%D0%B8%D1%81%D0%BA+%D0%B2+Google&as_epq=&as_oq=&as_eq=&as_sitesearch=&safe=images&as_st=y&tbs=isz:lt,islt:qsvga,ic:color&biw=1680&bih=895"