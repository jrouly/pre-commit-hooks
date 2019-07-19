#!/bin/bash -eu

DIR=$( cd $( dirname "${BASH_SOURCE[0]}") && pwd )

CONF_FOLDER=$DIR/scalafmt/conf
CONF_NAME=default.conf

# Parse args for files and conf name
FILES=""
while (( "$#" )); do
  case "$1" in
    --conf-name=*)
      CONF_NAME=$(echo $1 | cut -d '=' -f 2)
      if [[ $1 != *.conf ]]
      then
        CONF_NAME="$CONF_NAME.conf"
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      if [[ ! -f $1 ]]
      then
        echo "Invalid arg specified: $1"
        exit 1
      fi
      if [[ -z "$FILES" ]]
      then
        FILES=$1
      else
        FILES="$FILES,$1"
      fi
      ;;
  esac
  shift
done

# If there are no files to process, exit
if [[ -z $FILES ]]
then
  exit 0
fi

CONF_FILE=$CONF_FOLDER/$CONF_NAME

if [[ ! -f $CONF_FILE ]]
then
  echo "Invalid conf name supplied: $CONF_NAME"
  exit 1
fi

# Copy scalafmt config to app directory
cp -f $CONF_FILE $(git rev-parse --show-toplevel)/.scalafmt.conf

# If running on mac os, use darwin binary, else use linux binary
if uname | grep "Darwin" > /dev/null
then
  SCALAFMT=scalafmt-native-darwin-2.0.0
else
  SCALAFMT=scalafmt-native-linux-2.0.0
fi

$DIR/scalafmt/$SCALAFMT -c $CONF_FILE -i -f $FILES