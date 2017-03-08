#!/bin/sh -e


DEST='/tmp'

fail () {
  echo "$1" > /dev/stderr
  exit 1
}

s3get () {
  REMOTE_FILE=`cat config.txt`
  CURRENT_FILE=`[[ ! -f /data/rev.txt ]] || (cat /data/rev.txt)`

  echo "remote file: $REMOTE_FILE"
  echo "current file: $CURRENT_FILE"

  if [[ "$CURRENT_FILE" = "" ]] || [[ "$CURRENT_FILE" != "$REMOTE_FILE" ]]; then
    echo "downloading from s3"

    mkdir -p /s3-archives

    aws s3 cp s3://${AWS_BUCKET}/${REMOTE_FILE}  ${DEST}/${REMOTE_FILE}

    if [[ $? != 0 ]]; then  echo "${REMOTE_FILE} doesn't exist in s3"; return; fi;

    echo "finished downloading from s3"

    echo "extracting files"

    mkdir -p "/s3-archives/$REMOTE_FILE"
    tar -xf ${DEST}/${REMOTE_FILE} -C "/s3-archives/$REMOTE_FILE"
    BASE_FOLDER=`ls /s3-archives/$REMOTE_FILE` && BASE_FOLDER="$(basename ${BASE_FOLDER})"

    rsync -av --delete "/s3-archives/$REMOTE_FILE/$BASE_FOLDER/" /data/
    ls "/s3-archives/$REMOTE_FILE/$BASE_FOLDER/"
    touch /data/update.lock
    echo ${REMOTE_FILE} > /data/rev.txt

    ls /s3-archives | grep -v  $REMOTE_FILE | awk '{print  "rm -rf /s3-archives/" $1}' | sh

    echo "done"
  fi
}

while true; do
s3get
sleep 3
done
