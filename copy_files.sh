#!/bin/bash
#Copyright (c) 2011, Thomas Eggum
#All rights reserved.

#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the <organization> nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.

#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL Thomas Eggum BE LIABLE FOR ANY
#DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#if [ $# -ne 2 ]; then
#    echo Usage ./copy_files.sh sourceFolder destinationFolder
#    exit 1
#else

if [ $# -eq 0 ]
  then
    echo "Usage ./copy_files.sh sourcefolder destinationfolder"
    exit 0
fi

find $1 \( -iname "*.MOV" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.cr2" -o -iname "*.mp4" -o -iname "*.tif" \) | 
	while read i; do		
		f="${i##*/}"

		response=$(exiftool -CreateDate "$i") 
		t=${response##* : };
		a=(`echo $t | sed -e 's/[:-]/ /g'`)
		datePathName=${a[0]}-${a[1]}-${a[2]}
		mkdir -p "$2/$datePathName"

		checksumString=$(cksum "$i")
		checksumArray=($checksumString)
		checksum=${checksumArray[0]}
		
		destinationFile=$2/$datePathName/$checksum"_"$f
		if [ -f $destinationFile ] #verify checksum if duplicate exist, and handle
			fileDiff=$(diff $destinationFile $i)
			then
			if [ "$fileDiff" != "" ]; then
  				echo File "$i" file exist, but content differ. Please verify!!
			fi
    	else #File does not exist, copy 
    		#echo copying "$i" $destinationFile
			cp "$i" $destinationFile
		fi
	done
exit 0
