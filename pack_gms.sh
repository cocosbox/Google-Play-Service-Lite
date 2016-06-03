#!/bin/sh

#
# Pack Google Play Services >= 30 in one jar file
#

#
# Author: Jimmy Yin (jimmy.yin5@gmail.com)
#

PLAY_SERVICES_PATH=$ANDROID_SDK_ROOT/extras/google/m2repository/com/google/android/gms
PLAY_SERVICES_VERSION=9.0.1

PLAY_SERVICES_FILENAME="google-play-services.jar"
PLAY_SERVICES_TEMP_DIR="google-play-services-temp"
PLAY_SERVICES_STRIP_FILE="config.conf"
PLAY_SERVICES_NESTED_PATH="com/google/android/gms"
PLAY_SERVICES_OUTPUT_FILE="google-play-services-full.jar"

# Check if file exists in the same directory
if [ ! -d $PLAY_SERVICES_PATH ]; then
    echo "\nPlease config $ANDROID_SDK_ROOT, then run it again\n\n"
    exit -1
fi

# Preventive cleanup
rm -rf $PLAY_SERVICES_TEMP_DIR

# Create temporary work folder
mkdir $PLAY_SERVICES_TEMP_DIR
cd $PLAY_SERVICES_TEMP_DIR

# If the configuration file doesn't exist, create it
if [ ! -f ../$PLAY_SERVICES_STRIP_FILE ]; then
    # Create the file
    touch ../$PLAY_SERVICES_STRIP_FILE
    FOLDERS=`ls $PLAY_SERVICES_PATH`
    for index in $FOLDERS
    do
        echo "$index=true" >> ../$PLAY_SERVICES_STRIP_FILE
    done

    sed "1d" ../$PLAY_SERVICES_STRIP_FILE > ../$PLAY_SERVICES_STRIP_FILE.bak
    sed "s/play-services-//g" ../$PLAY_SERVICES_STRIP_FILE.bak > ../$PLAY_SERVICES_STRIP_FILE
fi

# Read configuration from file
while read -r FOLDERS
do
    CURRENT_FOLDER=$FOLDERS
    CURRENT_FOLDER_NAME=`echo $CURRENT_FOLDER | awk -F'=' '{print $1}'`
    CURRENT_FOLDER_ENABLED=`echo $CURRENT_FOLDER | awk -F'=' '{print $2}'`

    if [ "$CURRENT_FOLDER_ENABLED" = true ]; then
        ARR_FILE=$PLAY_SERVICES_PATH/play-services-$CURRENT_FOLDER_NAME/$PLAY_SERVICES_VERSION/play-services-$CURRENT_FOLDER_NAME-$PLAY_SERVICES_VERSION.aar

        echo "Extracting " $CURRENT_FOLDER_NAME
        if [ -f $ARR_FILE ]; then
            unzip $ARR_FILE -d $CURRENT_FOLDER_NAME      > /dev/null
        fi
        if [ -f $CURRENT_FOLDER_NAME/classes.jar ]; then
            jar xvf $CURRENT_FOLDER_NAME/classes.jar     > /dev/null
        fi
        echo "Extracting Done\n"
    else
        echo "Skip extracting " $CURRENT_FOLDER_NAME "\n"
    fi
done < ../"$PLAY_SERVICES_STRIP_FILE"

# Create final stripped JAR
jar cf $PLAY_SERVICES_OUTPUT_FILE com/
cp $PLAY_SERVICES_OUTPUT_FILE ../$PLAY_SERVICES_FILENAME
cd ..

# Clean up
echo "\nFolders removed, cleaning up.."
rm -rf $PLAY_SERVICES_TEMP_DIR
rm -fr $PLAY_SERVICES_STRIP_FILE.bak

echo "All done, exiting!"
exit 0
