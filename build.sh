#!/bin/bash
set -e
if [ "$1" == "new" ] || [ "$2" == "new" ];then
  repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r15 --depth=1
  wget https://github.com/aosp-tissot/local_manifest/raw/aosp-10.0/local_manifest.xml .repo/local_manifest.xml
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-11.0/patch.sh
  wget https://github.com/phhusson/treble_experimentations/releases/download/v300.g/patches.zip
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-11.0/patch.zip
  unzip ./patches.zip
  unzip ./patch.zip
  repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
  bash patch.sh ./
  patch -p1 < patch.txt
  cd frameworks/base
#  git fetch https://github.com/aosp-tissot/platform_frameworks_base-1.git Q
#  git cherry-pick 7dcb550f5f267b4d275240c9d29c331cfedde42b
  git fetch "https://github.com/LineageOS/android_frameworks_base" refs/changes/06/267306/21 && git cherry-pick FETCH_HEAD
  cd -
fi
if [ "$1" == "clean" ] || [ "$2" == "clean" ];then
  repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r15
  repo forall -c 'git reset --hard ; git clean -fdx'
  if [ -f "patches.zip" ]; then
     rm patches.zip
  fi
  if [ -d "patches" ]; then
     rm -rf patches
  fi
  wget https://github.com/phhusson/treble_experimentations/releases/download/v300.g/patches.zip
  unzip ./patches.zip
  repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
  bash patch.sh ./
  patch -p1 < patch.txt
  cd frameworks/base
  git fetch https://github.com/aosp-tissot/platform_frameworks_base-1.git R
  git cherry-pick cd1374b20efccf83140a9c67d6ca18dcb2f46c85 64e57deceede996181bb13d4990c09e17cb39c44
  git cherry-pick f02d9c03ec0de0e33f8ada16e0789988828b6487^..d1e35f3c072aee2fe6e3dee4da7e9b067a66e72d
#  git fetch "https://github.com/LineageOS/android_frameworks_base" refs/changes/06/267306/21 && git cherry-pick FETCH_HEAD
  cd -
fi
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
make -j4 systemimage
xz -c -v ./out/target/product/phhgsi_arm64_ab/system.img -T4 > system.img.xz
