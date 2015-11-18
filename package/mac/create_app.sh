#!/bin/bash

cd ../../
mkdir -p gui/deploy

set -e

# Extract the version numbers. 
majorVersion=$( sed -n 's/^.*final int MAJOR_VERSION = //p' common/src/main/java/io/bitsquare/app/Version.java )
minorVersion=$( sed -n 's/^.*final int MINOR_VERSION = //p' common/src/main/java/io/bitsquare/app/Version.java )
patchVersion=$( sed -n 's/^.*final int PATCH_VERSION = //p' common/src/main/java/io/bitsquare/app/Version.java )

# remove trailing;
majorVersion="${majorVersion:0:${#majorVersion}-1}"
minorVersion="${minorVersion:0:${#minorVersion}-1}"
patchVersion="${patchVersion:0:${#patchVersion}-1}"

fullVersion=$( sed -n 's/^.*final String VERSION = "//p' common/src/main/java/io/bitsquare/app/Version.java )
# remove trailing ";
fullVersion=$majorVersion.$minorVersion.$patchVersion

echo majorVersion = $majorVersion
echo minorVersion = $minorVersion
echo patchVersion = $patchVersion
echo fullVersion = $fullVersion

# Generate the plist from the template
sed "s|JAR_NAME_STRING_GOES_HERE|$patchVersion.jar|" package/mac/Info.template.plist >package/mac/Info.plist


mvn clean package -DskipTests -Dmaven.javadoc.skip=true
cp gui/target/shaded.jar gui/deploy/Bitsquare.jar

$JAVA_HOME/bin/javapackager \
    -deploy \
    -BappVersion=$fullVersion \
    -Bmac.CFBundleIdentifier=io.bitsquare \
    -Bmac.CFBundleName=Bitsquare \
    -Bicon=package/mac/Bitsquare.icns \
    -Bruntime="$JAVA_HOME/../../" \
    -native dmg \
    -name Bitsquare \
    -title Bitsquare \
    -vendor Bitsquare \
    -outdir gui/deploy \
    -srcfiles gui/target/shaded.jar \
    -appclass io.bitsquare.app.BitsquareAppMain \
    -outfile Bitsquare \
    -BjvmProperties=-Djava.net.preferIPv4Stack=true
    
cd package/mac