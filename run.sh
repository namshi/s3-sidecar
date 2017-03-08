#!/bin/sh -e

CONFIG_PATH=${CONFIG_PATH}

DEST='/tmp'

fail () {
  echo "$1" > /dev/stderr
  exit 1
}

s3get () {
  FILE_NAME=`echo $CONFIG_PATH | awk -F/ '{print $NF}'`
  CURRENT_FILE=`[[ ! -f /data/${FILE_NAME} ]] || (cat /data/${FILE_NAME})`

  echo "remote file: $FILE_NAME"
  echo "current file: $CURRENT_FILE"

  if [[ "$CURRENT_FILE" = "" ]] || [[ "$CURRENT_FILE" != "$FILE_NAME" ]]; then
    echo "downloading from s3"

    mkdir -p /s3-archives

    aws s3 cp s3://${AWS_BUCKET}/${FILE_NAME}  ${DEST}/${FILE_NAME}

    if [[ $? != 0 ]]; then  fail "${FILE_NAME} doesn't exist in s3"; fi;

    echo "finished downloading from s3"

    echo "extracting files"

    mkdir -p "/s3-archives/$FILE_NAME"
    tar -xf ${DEST}/${FILE_NAME} -C "/s3-archives/$FILE_NAME"
    BASE_FOLDER=`ls /s3-archives/$FILE_NAME` && BASE_FOLDER="$(basename ${BASE_FOLDER})"

    rsync -av --delete "/s3-archives/$FILE_NAME/$BASE_FOLDER/" /data/

    touch /data/update.lock
    echo ${FILE_NAME} > /data/${FILE_NAME}

    ls /s3-archives | grep -v  $FILE_NAME | awk '{print  "rm -rf /s3-archives/" $1}' | sh

    echo "done"
  fi
}

while true; do
s3get
sleep 3
done
