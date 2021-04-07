#!/bin/bash
apkFile=build/app/outputs/flutter-apk/app-release.apk
if [ -e $apkFile ]
then
	adb install -r build/app/outputs/flutter-apk/app-release.apk
else
	flutter build apk --target-platform android-arm
	adb install -r build/app/outputs/flutter-apk/app-release.apk
fi
rm $apkFile