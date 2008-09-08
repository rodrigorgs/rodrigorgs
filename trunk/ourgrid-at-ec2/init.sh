#!/bin/bash

PEER_FILE=peer-3.3.2.tar.gz
UA_FILE=useragent-3.3.1.tar.gz
PEER_URL=http://www.ourgrid.org/twiki-public/pub/OG/OurDownload/$PEER_FILE
UA_URL=http://www.ourgrid.org/twiki-public/pub/OG/OurDownload/$UA_FILE

sed -i /etc/resolv.conf -e 's/nameserver.*/nameserver 208.67.222.222/'
wget $UA_URL
tar xzf $UA_FILE

#if [ $with_peer ]; then
#	wget $PEER_URL
#	tar xzf $PEER_FILE
#
#	cd peer
#	bin/peer start
#	#bin/peer setgums ...
#	cd ..
#fi


