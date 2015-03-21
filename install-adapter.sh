#!/bin/bash

WORK_DIR=`dirname $0`
pushd $WORK_DIR
WORK_DIR=`pwd`
popd
WSMANCMD="/etc/maas/templates/power/wsmancmd.py"

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
sudo apt-get -y install python-pip
CheckError "Failed to install python-pip"
sudo pip install pywinrm
CheckError "Failed to install pywinrm"

pushd /

echo "Patching MaaS to enable Hyper-V power adapter"
sudo patch -p1 < "$WORK_DIR/patch.diff"
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
