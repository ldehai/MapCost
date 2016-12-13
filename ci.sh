#!/bin/bash
#author:ldehai@gmail.com
#github:
#1 设置各项根目录
PROJ_PATH="/Users/andy/labs/MapCost"
INFO_PATH="/Users/andy/labs/MapCost/MapCost/MapCost-Info.plist"
BUILD_PATH="/Users/andy/labs/MapCost/build"
APP_PATH="/Users/andy/labs/MapCost/release"

#2 进入项目目录
cd $PROJ_PATH

#3 设置Info.plist版本
appversion=1.0
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString '${appversion}'" $INFO_PATH
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion '${appversion}'" $INFO_PATH

#4 编译app
echo "building..."
      xcodebuild
			-project MapCost.xcodeproject   #指定project
			-scheme MapCost                  #指定schema
			VALID_ARCHS="arm64 armv7 armv7s"    #指定archs
			-configuration Debug clean build CONFIGURATION_BUILD_DIR=$BUILD_PATH  #自定义编译输出路径
			CODE_SIGN_IDENTITY="iPhone Distribution: DeHai Liu"   #签名
			PROVISIONING_PROFILE="db0d6e60-9b03-45ab-8009-7cd25cf00cc8"  #设置provisioning，要使用证书的uuid，不能直接用名字

#5 打包ipa
appfile=$BUILD_PATH/MapCost.app
ipafile=$APP_PATH/MapCost.ipa

rm -r $APP_PATH/MapCost.ipa
/usr/bin/xcrun -sdk iphoneos PackageApplication -v $appfile -o $ipafile
