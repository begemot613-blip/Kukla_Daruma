
#!/bin/sh

HOST=$2
#192.168.1.26
PORT=8987
HASH=$1
#7d1a4b8134c662c52e88aaf4f041dcdde8f3b72d
PLAYLIST=/tmp/torrest_pls_$HASH.m3u


echo "#EXTM3U" > $PLAYLIST


for var in ` wget -qO - http://$HOST:$PORT/torrents/$HASH/files | jq -r '.[].name ' | grep -i -n -E '\.mkv|\.mp4|\.avi|\.mov|\.webm|\.wmv' |sed 's/ /_/g' | awk -F':' '{print $2, $1 }' |sort -V |sed 's/ /%20/g'`

do
echo '#EXTINF:-1,'"`echo $var | awk -F'%20' '{print $1 }' `" >> $PLAYLIST
NUM=`echo $var | awk -F'%20' '{print $2 }'`
echo http://$HOST:$PORT/torrents/$HASH/files/`echo $NUM -1 |bc`/serve >> $PLAYLIST
done
