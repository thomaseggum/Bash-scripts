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
		
	    #flytte fil til mappestruktur

	    # sjekke om canon?
	    cameraModel=$(exiftool "$file" | grep "Camera Model")
		basePath=$mobileFolder
		if [[ $cameraModel == *Canon* ]]; then
			basePath=$canonFolder
		fi

		#START HANDLING EXIF
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

		#NOW deal with duplicates
		#Create destination file name
		checksumString=$(cksum "$file")
		checksumArray=($checksumString)
		checksum=${checksumArray[0]}
		destinationFile=$imageFolderName/$checksum"_"$f

		#Handle copy image

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
