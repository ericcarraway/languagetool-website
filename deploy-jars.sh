#!/bin/sh
# Copy the latest LanguageTool JARs to Tomcat for community.languagetool.org
# Run this after a new snapshot has been created.
# dnaber, 2014-03-04

SNAPSHOT_DIR=../languagetool-website/www/download/snapshots
WEB_LIB=/home/languagetool/tomcat/webapps/ROOT/WEB-INF/lib
DATE=`date +%Y%m%d`

if [ $# = 1 ]; then
  DATE=$1
fi

echo "Using date: $DATE"

cd /home/languagetool/languagetool.org/git-checkout
rm -r /tmp/lt-snapshot
rm -r /tmp/lt-wikipedia-snapshot

SNAPSHOT=$SNAPSHOT_DIR/LanguageTool-$DATE-snapshot.zip
if [ ! -f $SNAPSHOT ]; then
  echo "$SNAPSHOT not found, stopping"
  exit
fi

unzip -d /tmp/lt-snapshot $SNAPSHOT

# backup of libs:
rm -r /home/languagetool/tomcat/lib-bak/
mkdir /home/languagetool/tomcat/lib-bak/
cp -r $WEB_LIB /home/languagetool/tomcat/lib-bak/

cp /tmp/lt-snapshot/LanguageTool-*-SNAPSHOT/libs/languagetool-core.jar $WEB_LIB
cp /tmp/lt-snapshot/LanguageTool-*-SNAPSHOT/libs/languagetool-core-tests.jar $WEB_LIB

cd /tmp/lt-snapshot/LanguageTool-*-SNAPSHOT/
rm /tmp/lt-not-in-jars.jar
zip -r /tmp/lt-not-in-jars.jar org/
cp /tmp/lt-not-in-jars.jar $WEB_LIB
# get rid of language-it-2.5-SNAPSHOT.jar etc to avoid duplication:
rm $WEB_LIB/language-..-*-SNAPSHOT.jar

mkdir -p /home/languagetool/tomcat/webapps/ROOT/WEB-INF/classes/META-INF/org/languagetool/
cp /tmp/lt-snapshot/LanguageTool-*-SNAPSHOT/META-INF/org/languagetool/language-module.properties /home/languagetool/tomcat/webapps/ROOT/WEB-INF/classes/META-INF/org/languagetool/

unzip -d /tmp/lt-wikipedia-snapshot $SNAPSHOT_DIR/LanguageTool-wikipedia-$DATE-snapshot.zip
cp /tmp/lt-wikipedia-snapshot/LanguageTool-*-SNAPSHOT/languagetool-wikipedia.jar $WEB_LIB

cd /home/languagetool
./restart-tomcat.sh