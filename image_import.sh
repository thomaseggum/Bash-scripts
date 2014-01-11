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


say "Start image script"
canonFolder=$(eval echo ~${SUDO_USER})/Pictures/
mobileFolder=$(eval echo ~${SUDO_USER})/Pictures/mobilbilder
mkdir -p "$canonFolder/NO_EXIF_FILES"
mkdir -p "$mobileFolder/NO_EXIF_FILES"
sourceFolder=$(eval echo ~${SUDO_USER})/camera_dump
echo START
i=0
oldI=0
while [[ true ]]; do
	oldI=$i
	while read -r file
	do
		if [ $i -eq 0 ]; then
			say "start copy images"
		fi
	    (( i++ ))
		
	    #differ camera models
	    cameraModel=$(exiftool "$file" | grep "Camera Model")
		basePath=$mobileFolder
		if [[ $cameraModel == *Canon* ]]; then
			basePath=$canonFolder
		fi

		#extract exif for destination folder
		f="${file##*/}"
		imageFolderName=$basePath/NO_EXIF_FILES #defaults
		response=$(exiftool -CreateDate "$file") 
		responseLength=$(echo ${#response})

		if [ $responseLength -gt 0 ]; then
			t=${response##* : };
			a=(`echo $t | sed -e 's/[:-]/ /g'`)
			yearFolderName=${a[0]}		

			datePathName=${a[0]}-${a[1]}-${a[2]}
			imageFolderName="$basePath/$yearFolderName/$datePathName"
			mkdir -p "$imageFolderName"
		fi	

		#create unique file names
		checksumString=$(cksum "$file")
		checksumArray=($checksumString)
		checksum=${checksumArray[0]}
		destinationFile=$imageFolderName/$checksum"_"$f

		#move images to folder structure
		if [ -f "$destinationFile" ]; then
			rm "$file"
			fileDiff=$(diff $destinationFile "$file")
			if [ "$fileDiff" != "" ]; then
  				echo File "$file" file exist, but content differ. Please verify!!
			fi
    	else
			mv "$file" "$destinationFile"
			chmod 650 "$destinationFile"
		fi	

	done < <(find "$sourceFolder" \( -iname "*.PNG" -o -iname "*.MOV" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.cr2" -o -iname "*.mp4" -o -iname "*.tif" \) ) 

	if [ $oldI -eq $i ] && [ $i -ne 0 ]; then
		say "done copying images"
		oldI=0
		i=0
	fi
    sleep 2    
done
