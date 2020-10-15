# local_manifest
Instructions:
1. Download all needed requirements from: https://source.android.com/setup/build/initializing
2. Make a new folder called 'aosp'
3. download build.sh script to that folder
4. run the script using build.sh $MODE $DEVICE_TYPE,
for example for an arm64 device with pie and newer vendor (like curtana or tissot, doogee y8 etc) with gapps, you would enter:

'bash build.sh new arm64-gapps'

the script will download the target aosp in the script, download all the patches, patch the repos, build and finally compress the system.img, output will be in the aosp directory,
file called 'system.img.xz

build.sh switches: 

'new': this mode must be run the first time you run the script, followed by the build type you want
'clean': this will just clean the system output, its not a full clean but good enough for incremental builds. this must also be run everytime to avoid issues. (won't change build time almost at all)

Build.sh Device types:

'arm64-gapps': builds a gsi with gapps for arm64 devices with pie vendor and newer

'arm64-gapps-go': android go build for arm64 with gapps go

'arm32-gapps-go': android go build for arm32 with gapps go

'arm64-vanilla': GSI arm64 vanilla (no gapps)
