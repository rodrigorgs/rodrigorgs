#!/bin/bash
# This script configures a OurGrid Worker on a pre-configured AMI (Amazon
# Machine Image)

# This section must be configured before this script can be used
# Please surround the values with single quotes (') and precede each slash (/)
# with a backslash (\).

USER=USERNAME
PASS=PASSWORD
KEY=PEER_PUBLIC_KEY
SERVER=xmpp.ourgrid.org

###################################################

KEY_SERVER=commune.xmpp.servername
KEY_USER=commune.xmpp.username
KEY_PWD=commune.xmpp.password
KEY_PEER_PK=worker.peer.publickey
WORKER_DIR=/root/worker-4.0alpha3

cd $WORKER_DIR

sed -i worker.properties -e "s/$KEY_SERVER\\=.*$/$KEY_SERVER=$SERVER/"
sed -i worker.properties -e "s/$KEY_PEER_PK\\=.*$/$KEY_PEER_PK=$KEY/"
sed -i worker.properties -e "s/$KEY_USER\\=.*$/$KEY_USER=$USER/"
sed -i worker.properties -e "s/$KEY_PWD\\=.*$/$KEY_PWD=$PASS/"

sh worker start

