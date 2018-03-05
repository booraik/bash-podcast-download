#!/bin/sh
# 
#
# Description: A simple bash script to download all media from a podcast XML feed
#
# Usage: sh podcast-download.sh http://myfeed.com/rss /PATH/TO/FOLDER
#
# Author: Andrew Morton
# Url: https://github.com/mortocks/bash-podcast-download
#
# Licence: GNU v3.0
 

# Optional Variables
# You can hardcode the feed and url variables here to avoid sending them when envoking the script
#FEED='' # URL TO THE RSS FEED
FEED='http://api.podty.me/api/v1/share/cast/390937d3e5c758aa6f4005b63542cc83695b4d5e6925fe6a2d4d488d1d05d748/146364 ' # URL TO THE RSS FEED
#FOLDER='' # RELATIVE PATH OF FOLDER TO DOWNLOAD FILES TO
FOLDER='/home/media/podcasts/지대넓얕/' # RELATIVE PATH OF FOLDER TO DOWNLOAD FILES TO

RSSFILE=.tmp.rss
wget $FEED --output-document $RSSFILE

# Override hardcoded feeds with passed variables
#[ -n "$1" ] && FEED=$1
#[ -n "$2" ] && FOLDER=$2

# Check if feed is empty
if [ -z "$FEED" ]; then
	echo "Error: No feed specified"; exit
fi

# Check if path is empty
if [ -z "$FOLDER" ]; then
	echo "Error: No folder specified"; exit
fi

# Create destination folder if it doesn't exsist
if [ -d $FOLDER ]; then
	echo "$FOLDER exists"
else 
	echo "Creating directory $FOLDER"
	mkdir $FOLDER
fi 

# Check package
if ! type "xpath" > /dev/null; then
	yum install perl-XML-XPath -y
fi
if ! type "curl" > /dev/null; then
	yum install curl -y
fi
if ! type "wget" > /dev/null; then
	yum install wget -y
fi

STARTTIME=`date +%s`

# Get the full XML feed | extract the enclosure url attribute | extract the url
MEDIA=$(cat $RSSFILE | xpath '/rss/channel/item/enclosure/@url' 2>/dev/null | egrep -o 'https?://[^"<]+' )

# Loop through and download file if not already downloaded
cnt=1
while IFS= read -r URL
do
    echo --- $cnt --- st download
	# Find the last part of the url using the / as delimiter
	AFTER_SLASH=${URL##*/}

	# Remove any additional query params in the filename by removing everything after ?
    #FILE_NAME=${AFTER_SLASH%%\?*}
    EXT=$(echo $URL |awk -F . '{if (NF>1) {print $NF}}')
    PREFIX=$(cat $RSSFILE | xpath '/rss/channel/item['$cnt']/pubDate' 2>/dev/null | sed -n -e 's/.*<pubDate>\(.*\)<\/pubDate>.*/\1/p' )
    PREFIX=`date -d "$PREFIX" "+%Y%m%d"`
    TITLE=$(cat $RSSFILE | xpath '/rss/channel/item['$cnt']/title' 2>/dev/null | sed -n -e 's/.*<title>\(.*\)<\/title>.*/\1/p' )
    TITLE=$(echo $TITLE |  sed 's/[?<>\\:*|\"\/]/_/g')
    
    FILE_NAME=$PREFIX'_'$TITLE'.'$EXT

    DATE=$(date)
    echo DATE : $DATE

	# If file as already been downloaded ignore
	if [ -f "$FOLDER/$FILE_NAME" ]; then
		echo "$FOLDER/$FILE_NAME already exists"
	else 
        echo URL : $URL
        echo FOLDER : $FOLDER
        echo FILE_NAME : $FILE_NAME
        curl -s -L $URL > "$FOLDER/$FILE_NAME"
        #echo "Download $URL $FOLDER/$FILE_NAME $FILE_NAME $DATE"
        #curl -s -L $URL > $FOLDER/$FILE_NAME
	fi 
    cnt=$(($cnt+1))
done <<< "$MEDIA"

ENDTIME=`date +%s`
rm $RSSFILE
echo Finished total time `expr $ENDTIME - $STARTTIME`s.

