#!/bin/bash
# Orders a container using docker run command.
# The container command is responsible to

SID=$1
GRADER_HOST=$2
DOCKER_IMAGE=$3
EXERCISE_MOUNT=$4
SUBMISSION_MOUNT=$5
CMD=$6
COURSE_JSON=$7
EXERCISE_JSON=$8

# Manage for docker-compose setup, see test course for reference.
# Docker cannot bind volume from inside docker so global /tmp is used.
TMP=/tmp/aplus
TMP_EXERCISE_MOUNT=$TMP/_ex/${EXERCISE_MOUNT##/srv/courses/}
TMP_SUBMISSION_MOUNT=$TMP/${SUBMISSION_MOUNT##/srv/uploads/}
rm -rf $TMP_EXERCISE_MOUNT
mkdir -p $TMP_EXERCISE_MOUNT
mkdir -p $TMP_SUBMISSION_MOUNT
cp -r $EXERCISE_MOUNT $(dirname $TMP_EXERCISE_MOUNT)
cp -r $SUBMISSION_MOUNT $(dirname $TMP_SUBMISSION_MOUNT)

# use Python to parse EXERCISE_JSON
# function: prints a value from the EXERCISE_JSON
# param $1: the key whose value should be returned
parse_val_from_exercise_json () {
  local parsejson="import json; print(json.loads('$EXERCISE_JSON').get('$1', ''))"
  echo $(python3 -c "$parsejson")
}

# in personalized exercises, we need the file path to the correct instance
PERSONALIZED_MOUNT=$(parse_val_from_exercise_json personalized_exercise)
# personal directory is an additional feature in the personalization, but it might
# be removed in the future since it is hacky and not really needed
PERSONAL_DIR_MOUNT=$(parse_val_from_exercise_json personal_directory)

# normal exercises do not use the personalized mount
PERSONALIZED_ARG=''
if [ -n "$PERSONALIZED_MOUNT" ]; then
  TMP_PERSONALIZED_MOUNT=$TMP/_personalized/${PERSONALIZED_MOUNT##/srv/data/mgrader_ex-meta/}
  rm -rf $TMP_PERSONALIZED_MOUNT
  mkdir -p $TMP_PERSONALIZED_MOUNT
  cp -r $PERSONALIZED_MOUNT $(dirname $TMP_PERSONALIZED_MOUNT)
  PERSONALIZED_ARG="-v $TMP_PERSONALIZED_MOUNT:/personalized_exercise"
fi
if [ -n "$PERSONAL_DIR_MOUNT" ]; then
  TMP_PERSONAL_DIR_MOUNT=$TMP/_personalized/${PERSONAL_DIR_MOUNT##/srv/data/mgrader_ex-meta/}
  rm -rf $TMP_PERSONAL_DIR_MOUNT
  mkdir -p $TMP_PERSONAL_DIR_MOUNT
  cp -r $PERSONAL_DIR_MOUNT $(dirname $TMP_PERSONAL_DIR_MOUNT)
  PERSONALIZED_ARG="$PERSONALIZED_ARG -v $TMP_PERSONAL_DIR_MOUNT:/personal_directory"
fi

docker run \
  -d --rm \
  -e "SID=$SID" \
  -e "REC=$GRADER_HOST" \
  -v $TMP_EXERCISE_MOUNT:/exercise \
  -v $TMP_SUBMISSION_MOUNT:/submission \
  $PERSONALIZED_ARG \
  --network=aplus_default \
  $DOCKER_IMAGE \
  $CMD

# update the contents of the personal directory after the grader has exited
if [ -n "$PERSONAL_DIR_MOUNT" ]; then
  cp -r $TMP_PERSONAL_DIR_MOUNT/* $PERSONAL_DIR_MOUNT
fi

