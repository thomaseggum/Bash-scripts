#!/bin/bash
Echo starting
COUNTER=0
find $1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.cr2" -o -iname "*.mp4" -o -iname "*.tif" \) | 
	while read i; do
		j=${i##*/}
		f="$COUNTER"_"${i##*/}"
		let COUNTER=COUNTER+1 

		#Read date from file
		response=$(exiftool -CreateDate "$i") 
		t=${response##* : };
		a=(`echo $t | sed -e 's/[:-]/ /g'`)
		datePathName=${a[0]}-${a[1]}-${a[2]}
		mkdir -p "$2/$datePathName"
		
		#echo copying "$i" "$2/$datePathName/$f"
		cp "$i" "$2/$datePathName/$f"
	done
exit 0