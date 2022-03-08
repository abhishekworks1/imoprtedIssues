#!/usr/bin/env bash

VERSION_CODE=$((VERSION_CODE_SHIFT + APPCENTER_BUILD_ID))
plutil -replace CFBundleVersion -string "$VERSION_CODE"
$APPCENTER_SOURCE_DIRECTORY/QuickCam-Info.plist
