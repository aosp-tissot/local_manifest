#!/bin/bash
set -e
threads="cat /proc/cpuinfo | grep processor | wc -l"
repo_init="repo init -u https://android.googlesource.com/platform/manifest -b android-12.0.0_r32 --depth=1"
phh_patch="wget -O patches.zip https://github.com/phhusson/treble_experimentations/releases/download/v402/patches-for-developers.zip"
sooti_patch="wget https://github.com/aosp-tissot/local_manifest/raw/aosp-12.0/patches.zip"
repo_sync="repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune"
if [ "$1" == "new" ] || [ "$2" == "new" ];then
  $repo_init
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-12.0/local_manifest.xml
  mkdir .repo/local_manifests
  mv local_manifest.xml ./.repo/local_manifests/
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-12.0/patch.sh
  $sooti_patch
  unzip ./patches.zip
  rm ./patches.zip
  $phh_patch
  unzip ./patches.zip
  rm ./patches.zip
  $repo_sync
  bash patch.sh ./
fi
if [ "$1" == "clean" ] || [ "$2" == "clean" ];then
  $repo_init
  repo forall -c 'git reset --hard ; git clean -fdx'
  if [ -f "patches.zip" ]; then
     rm patches.zip
  fi
  if [ -d "patches" ]; then
     rm -rf patches
  fi
  $phh_patch
  unzip ./patches.zip
  rm ./patches.zip
  $sooti_patch
  unzip ./patches.zip
  rm ./patches.zip
  $repo_sync
  bash patch.sh ./
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
   make installclean RELAX_USES_LIBRARY_CHECK=true
fi
make -j3 systemimage RELAX_USES_LIBRARY_CHECK=true
threads = "$(cat /proc/cpuinfo | grep processor | wc -l)"
xz -c -v ./out/target/product/phhgsi_arm64_ab/system.img -T$threads > system.img.xz
