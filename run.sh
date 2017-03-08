#!/bin/sh -e

CONFIG_PATH=${CONFIG_PATH}

DEST='/tmp'

fail () {
  echo "$1" > /dev/stderr
  exit 1
}

s3get () {
  NAME=`echo $CONFIG_PATH | awk -F/ '{print $NF}'`
  REMOTE_FILE=`cat ${CONFIG_PATH}`
  CURRENT_FILE=`[[ ! -f /data/${NAME} ]] || (cat /data/${NAME})`

  echo "remote file: $REMOTE_FILE"
  echo "current file: $CURRENT_FILE"

  if [[ "$CURRENT_FILE" = "" ]] || [[ "$CURRENT_FILE" != "$REMOTE_FILE" ]]; then
    echo "downloading from s3"

    mkdir -p /s3-archives

    aws s3 cp s3://${AWS_BUCKET}/${REMOTE_FILE}  ${DEST}/${REMOTE_FILE}

    if [[ $? != 0 ]]; then  fail "${REMOTE_FILE} doesn't exist in s3"; fi;

    echo "finished downloading from s3"

    echo "extracting files"

    mkdir -p "/s3-archives/$NAME"
    tar -xf ${DEST}/${REMOTE_FILE} -C "/s3-archives/$NAME"
    BASE_FOLDER=`ls /s3-archives/$NAME` && BASE_FOLDER="$(basename ${BASE_FOLDER})"

    rsync -a --delete "/s3-archives/$NAME/$BASE_FOLDER/" /data/

    touch /data/update.lock
    echo ${REMOTE_FILE} > /data/${NAME}

    rm -rf /s3-archives/${NAME}/*

    echo "done"
  fi
}

while true; do
s3get
sleep 3
done
