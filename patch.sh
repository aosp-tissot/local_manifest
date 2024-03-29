#!/bin/bash

set -e

patches="$(readlink -f -- $1)"
wget https://github.com/aosp-tissot/local_manifest/raw/aosp-11.0/sooti-patches.zip
unzip sooti-patches.zip
for project in $(cd $patches/patches; echo *) $(cd $patches/sooti-patches; echo *) ;do
        p="$(tr _ / <<<$project |sed -e 's;platform/;;g')"
        [ "$p" == build ] && p=build/make
        repo sync -l --force-sync $p
        pushd $p
        git clean -fdx; git reset --hard
        for patch in $patches/patches/$project/*.patch $patches/sooti-patches/$project/*.patch;do
                #Check if patch is already applied
                if patch -f -p1 --dry-run -R < $patch > /dev/null;then
                        continue
                fi

                if git apply --check $patch;then
                        git am $patch
                elif patch -f -p1 --dry-run < $patch > /dev/null;then
                        #This will fail
                        git am $patch || true
                        patch -f -p1 < $patch
                        git add -u
                        git am --continue
                else
                        echo "Failed applying $patch"
                fi
        done
        popd
done
