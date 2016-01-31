#! /bin/bash

cd src
rm -f ryte.love
zip -r ryte.love ./
/opt/android-sdk/platform-tools/adb push ryte.love /mnt/sdcard/ryte.love
rm -f ryte.love