#!/usr/bin/env sh
#
#  Created by Guillaume Cerquant - MacMation
#  http://www.macmation.com - contact AT macmation  DOT   com.
#  Copyright MacMation. All rights reserved.
#
# Version 1.3: Generate a .zip only when AppStore mode (because ipa is not recognized by Application loader)
# Version 1.2: Now generate an IPA file, with a label showing info version on the artwork iTunes icon
# Version 1.1: Include the Mobile Provisioning file inside the generated zip

# TODO:
# 	Explain what this script does
#
# Modified 2010-08-01 to use svn instead of bzr


# Call me quickly: ./Distribution.sh AdHoc && ./Distribution.sh AppStore

## configuration
# Project info
PROJECT_NAME="iPressbook"
TARGET_NAME="$PROJECT_NAME"
SDK="iphoneos4.3"
CONFIGURATION_NAME="AdHoc" # "AppStore" # ou AdHoc

# SVN_REPOSITORY_URL="http://macmation.unfuddle.com/svn/macmation_betteraccent/"
# SVN_USER_NAME="gcerquant"

FINAL_DIRECTORY="/Users/lv/Desktop"



# TODO: RENAME THIS OPTION
IMAGE_MAGICK_ENABLED="1";

IMAGE_MAGICK_CONVERT="/usr/local/bin/convert"
IMAGE_MAGICK_COMPOSITE="/usr/local/bin/composite"


# End of configuration

set -o errexit


if [ $# -ne "0" ]; then
	CONFIGURATION_NAME="$1";
	if [[ "$CONFIGURATION_NAME" != "AdHoc" && "$CONFIGURATION_NAME" != "AppStore" ]]; then
		echo "Unknown parameter";
		exit;
	fi
fi

CONFIGURATION="Distribution-${CONFIGURATION_NAME}"


XCODEBUILD="/Developer/usr/bin/xcodebuild"
BZR="/usr/local/bin/bzr"
SVN="/usr/bin/svn"

TEMP_DIRECTORY=`/usr/bin/mktemp -dq /tmp/${PROJECT_NAME}_XXXXXXXXXXXX`
if [ $? -ne 0 ]; then
	echo "$0: Can't create temp file, exiting..."
    exit 1
fi

SRC_DIRECTORY="${TEMP_DIRECTORY}/bzr"
BUILD_DIRECTORY="${TEMP_DIRECTORY}/build"


echo "Building $PROJECT_NAME (Target: $TARGET_NAME; SDK: $SDK; Configuration: $CONFIGURATION)"
echo "Temp: $TEMP_DIRECTORY"

$BZR export $SRC_DIRECTORY

# $SVN checkout --username "$SVN_USER_NAME" $SVN_REPOSITORY_URL $SRC_DIRECTORY
# cp -r "/Users/lv/Documents/DirectStar/src/Bollore_DirectStar" "$SRC_DIRECTORY" # TEMP - Use this line to not recheck out whole project when testing

BZR_REVNO=`/usr/local/bin/bzr revno`
# BZR_REVNO=`svn info | grep "^Revision: " | cut -d' ' -f2`
# echo "Revno: $BZR_REVNO"


SRC_DIRECTORY="$SRC_DIRECTORY" 
cd "${SRC_DIRECTORY}"
echo cd "${SRC_DIRECTORY}"

# Building project
echo ${XCODEBUILD} -target "$TARGET_NAME" -sdk "$SDK" -configuration "$CONFIGURATION" SYMROOT="${BUILD_DIRECTORY}"
${XCODEBUILD} -target "$TARGET_NAME" -sdk "$SDK" -configuration "$CONFIGURATION" SYMROOT="${BUILD_DIRECTORY}"


#############################################
# Getting Mobile Provisioning file
PATH_TO_EMBED_MOBILE_PROVISION_FILE="${BUILD_DIRECTORY}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.app/embedded.mobileprovision";
NAME_OF_MOBILE_PROVISION_FILE=`strings "${PATH_TO_EMBED_MOBILE_PROVISION_FILE}" | grep -A1 '<key>Name</key>' | tail -n1 | awk -F'<string>' '{print $2}' | awk -F'</string>' '{print $1}'`



echo "Mobile Provisioning Certificate used: ${NAME_OF_MOBILE_PROVISION_FILE}"

cp "${PATH_TO_EMBED_MOBILE_PROVISION_FILE}" "${BUILD_DIRECTORY}/${CONFIGURATION}-iphoneos/${NAME_OF_MOBILE_PROVISION_FILE}.mobileprovision"

#############################################




################################################

PRODUCT_VERSION_NUMBER=`cat ${PROJECT_NAME}-Info.plist | grep -A1 CFBundleVersion | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1`
# echo "Product version: ${PRODUCT_VERSION_NUMBER}"

DATE=`date '+%Y%m%d_%H'h'%M'`


BASEFILENAME="${PROJECT_NAME}_v${PRODUCT_VERSION_NUMBER}_(rev_${BZR_REVNO}-$DATE)_${CONFIGURATION_NAME}.zip" 
BASEFILENAME_FOR_dSYM_SYMBOLS_ARCHIVE="${PROJECT_NAME}_v${PRODUCT_VERSION_NUMBER}_(rev_${BZR_REVNO}-$DATE)_${CONFIGURATION_NAME}_dSYM_symbols.zip" 


cd "${BUILD_DIRECTORY}/${CONFIGURATION}-iphoneos"


if [ "$CONFIGURATION_NAME" = "AdHoc" ]; then
	
	echo "generating ipa ------------------------------------------------------------------------------------------------"
	
	# Generate IPA (only if AdHoc build)

	/bin/mkdir Payload

	mv "${PROJECT_NAME}.app" "Payload"

	/bin/cp "${SRC_DIRECTORY}/Icon_iTunes.png" "iTunesArtwork"

	# Add a text label to the image


	if [ ${IMAGE_MAGICK_ENABLED} -eq "1" ]; then
		if [ ! -x "${IMAGE_MAGICK_CONVERT}" ]; then
		 	echo "Please Install ImageMagick (http://www.imagemagick.org/script/install-source.php)\nor disable iTunes icon version tagging";
			exit 3;
		else

			# Create the text info label on a white semi transparent background
			${IMAGE_MAGICK_CONVERT} -size 512x -background '#FFFD'  -fill black  -font Monaco  -gravity South label:"     Version ${PRODUCT_VERSION_NUMBER} (beta)     \n     ${DATE}     " label.png

			# Composite the label and the original iTunes artwork
			${IMAGE_MAGICK_COMPOSITE} -gravity South label.png iTunesArtwork iTunesArtwork_labeled
	
			mv "iTunesArtwork_labeled" "iTunesArtwork"
	
		fi
	fi


	/usr/bin/zip -r -T -y "${PROJECT_NAME}.ipa" "Payload" "iTunesArtwork"


	################################################

fi



#############################################

# Create final archive


echo "Creating file: $BASEFILENAME"


if [ "$CONFIGURATION_NAME" = "AdHoc" ]; then
	# Ipa for AdHoc build
	zip -r -T -y "${BASEFILENAME}" "${PROJECT_NAME}.ipa" "${NAME_OF_MOBILE_PROVISION_FILE}.mobileprovision"
else
	# or .app for AppStore
	zip -r -T -y "${BASEFILENAME}" "${PROJECT_NAME}.app"
fi


echo "${BUILD_DIRECTORY}/${CONFIGURATION}-iphoneos"
mv "./${BASEFILENAME}" "${FINAL_DIRECTORY}"


############################################

# Archive the dSYM symbols
echo "Archiving the dSYM symbols"
zip -r -T -y "${BASEFILENAME_FOR_dSYM_SYMBOLS_ARCHIVE}" "${PROJECT_NAME}.app.dSYM"
mv "./${BASEFILENAME_FOR_dSYM_SYMBOLS_ARCHIVE}" "${FINAL_DIRECTORY}"




#############################################

open "${FINAL_DIRECTORY}"


# Cleaning up:
rm -rf ${TEMP_DIRECTORY}


/Users/lv/bin/growlnotify "$PROJECT_NAME: AdHoc Build Generation finished" -m "${BASEFILENAME}"$'\n'"Sdk: $SDK"

if [ "$CONFIGURATION_NAME" = "AppStore" ]; then
	osascript -e 'tell application "Application Loader" to activate'
fi

