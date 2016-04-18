#!/bin/bash

WORK_DIR=`dirname $0`
pushd $WORK_DIR
WORK_DIR=`pwd`
popd
WSMANCMD="/etc/maas/templates/power/wsmancmd.py"
VERSION=$(dpkg-query -W maas 2>/dev/null | awk '{print $2}')

MAAS19="^1.9"

if [ -z "$VERSION" ]
then
    echo "MAAS is not installed"
    exit 1
fi

PATCH_FILE="$WORK_DIR/patch.diff"

if [[ $VERSION =~ $MAAS19 ]]
then
    PATCH_FILE="$WORK_DIR/maas-1.9.patch"
fi

function CheckError() {
    ERRCODE=$?
    if [ $ERRCODE -ne 0 ]
    then
        echo $1
        exit $ERRCODE
    fi
}

sudo apt-get update
CheckError "Failed to run update"
sudo apt-get -y install python-pip git
CheckError "Failed to install python-pip"
sudo pip install git+https://github.com/cloudbase/pywinrm
CheckError "Failed to install pywinrm"

pushd /

echo "Patching MaaS to enable Hyper-V power adapter"
sudo patch -p1 < $PATCH_FILE
CheckError "Failed to patch maas"
if [ -f "$WSMANCMD" ]
then
    sudo chmod +x "$WSMANCMD"
fi


echo "Restarting Apache2"
sudo /etc/init.d/apache2 restart
CheckError "Failed to restart Apache2"
sleep 3
sudo restart maas-clusterd
CheckError "Failed to restart maas-clusterd"

popd
