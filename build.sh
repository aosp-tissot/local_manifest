#!/bin/bash
set -e
if [ "$1" == "new" ] || [ "$2" == "new" ];then
  repo init -u https://android.googlesource.com/platform/manifest -b android-10.0.0_r41
  wget https://github.com/aosp-tissot/local_manifest/raw/aosp-10.0/local_manifest.xml .repo/local_manifest.xml
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-10.0/patch.sh
  wget https://github.com/phhusson/treble_experimentations/releases/download/v222/patches.zip
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-10.0/patch.zip
  unzip ./patches.zip
  unzip ./patch.zip
  repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
  bash patch.sh ./
  patch -p1 < patch.txt
  cd frameworks/base
  git fetch https://github.com/aosp-tissot/platform_frameworks_base-1.git Q
  git cherry-pick 7dcb550f5f267b4d275240c9d29c331cfedde42b
  git fetch "https://github.com/LineageOS/android_frameworks_base" refs/changes/06/267306/21 && git cherry-pick FETCH_HEAD
  cd -
fi
if [ "$1" == "clean" ] || [ "$2" == "clean" ];then
  repo forall -c 'git reset --hard ; git clean -fdx'
  if [ -f "patches.zip" ]; then
     rm patches.zip
  fi
  if [ -d "patches" ]; then
     rm -rf patches
  fi
  wget https://github.com/phhusson/treble_experimentations/releases/download/v222/patches.zip
  unzip ./patches.zip
  repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
  bash patch.sh ./
  patch -p1 < patch.txt
  cd frameworks/base
  git fetch https://github.com/aosp-tissot/platform_frameworks_base-1.git Q
  git cherry-pick 7dcb550f5f267b4d275240c9d29c331cfedde42b
  git fetch "https://github.com/LineageOS/android_frameworks_base" refs/changes/06/267306/21 && git cherry-pick FETCH_HEAD
  cd -
fi
# cd -
# cd packages/apps/Settings
# git fetch https://github.com/aosp-tissot/platform_packages_apps_settings-1.git Q
# git cherry-pick 0bca40ad2551843736e055e921443710c1d007da
#cd -
cd device/phh/treble
bash generate.sh
cd -
. build/envsetup.sh
if [ "$1" == "arm64-gapps" ] || [ "$2" == "arm64-gapps" ];then
   lunch treble_arm64_bgN-user
fi
if [ "$1" == "arm64-gapps-go" ] || [ "$2" == "arm64-gapps-go" ];then
   lunch treble_arm64_boN-user
fi
if [ "$1" == "arm32-gapps-go" ] || [ "$2" == "arm32-gapps-go" ];then
   lunch treble_arm_aoN-user
fi
if [ "$1" == "arm64-vanilla" ] || [ "$2" == "arm64-vanilla" ];then
   lunch treble_arm64_bvN-user
fi
if [ "$1" == "clean" ];then
   make installclean
fi
make -j16 systemimage
