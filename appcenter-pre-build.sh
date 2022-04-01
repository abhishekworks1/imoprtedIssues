#!/usr/bin/env bash

echo "Hello Prebuild Script."
VERSION_CODE=$((VERSION_CODE_SHIFT + APPCENTER_BUILD_ID))
#plutil -replace CFBundleVersion -string "$VERSION_CODE" $APPCENTER_SOURCE_DIRECTORY/QuickCam-Info.plist
echo "Hello Prebuild Script END."
cat $APPCENTER_SOURCE_DIRECTORY/QuickCam-Info.plist
echo "Done"
