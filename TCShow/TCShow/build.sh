#build.sh
SDK=$compileEnv

#local run example:SDK=iphoneos5.0

XCODE_PATH=$XCODE_PATH$compileEnv

#local run example:XCODE_PATH=xcodebuild

cd TCShow

$XCODE_PATH -target dailybuild -configuration DailyBuild clean -sdk $SDK



if [ -e  build/DailyBuild-iphoneos/*.ipa ] ;then

cd build/DailyBuild-iphoneos;

cd ..

rm -r *;

cd ..;

fi

if [ -e  result ] ;then
rm -r result;
fi

mkdir result

$XCODE_PATH -target dailybuild -configuration DailyBuild -sdk $SDK

cp build/DailyBuild-iphoneos/*.ipa ../result/${BaseLine}_$(date +%Y%m%d%H%M%S).ipa





