#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -eu

##############################################################################
# Installs scalafmt via coursier and runs it at the command line for the
# provided files.
#
# Usage:
#   ./scalafmt.sh [--no-copy-conf] [--conf-name=<CONF_NAME>] [file ...]
#
# References
# - Scalafmt CLI - https://scalameta.org/scalafmt/docs/installation.html#coursier
# - Coursier CLI - https://get-coursier.io/docs/cli-overview
#
# Notes:
# - Previous versions of this script used scalafmt-native binaries. But there
# were no instructions on how to update them or where they came from. I guess
# here https://github.com/mroth/scalafmt-native but I can't confirm. So I've
# updated these to use coursier which is one of the recommended approaches.
# - We intentionally do not keep the file downloaded by coursier's
##############################################################################

COURSIER_VERSION=v2.0.0-RC6-8
COURSIER_URL=https://github.com/coursier/coursier/releases/download/$COURSIER_VERSION/coursier
# We use this version because last time I tried to updated to 2.4.2 it introduced unexpected changes
SCALAFMT_VERSION=2.0.0

SOURCE_DIR=$(dirname "${BASH_SOURCE[0]}")
CURR_DIR=$(cd "$SOURCE_DIR" && pwd)

# _most_ systems have TMPDIR, but guess who doesn't? and has CACHE_DIR instead?... JENKINS!!! :rageface:
TMPDIR=${TMPDIR:-${CACHE_DIR:-"/tmp"}}

SCALAFMT_FOLDER=$CURR_DIR/scalafmt
CONF_FOLDER=$SCALAFMT_FOLDER/conf
COURSIER_CLI=$SCALAFMT_FOLDER/coursier-$COURSIER_VERSION
SCALAFMT_CLI=$SCALAFMT_FOLDER/scalafmt-$SCALAFMT_VERSION

# move the cache somewhere safe to write, as this can fail with the default location on Jenkins
# this is done here since it is used by both coursier itself and the scalafmt launcher that coursier builds
# https://get-coursier.io/docs/cache.html#manual-override
export COURSIER_CACHE="$TMPDIR/coursier"
mkdir -p "$COURSIER_CACHE"

# -conf-name - configuration file name, default will be overwritten if specified
CONF_NAME=default.conf
# --no-copy-conf - Flag to disable copying the conf to the root of the git clone
COPY_CONF=true
# Comma separated line of file names within $CURR_DIR
# This will be parsed from the args for files and conf name
FILES=""

# Downloads coursier-cli so we can download scalafmt
# https://get-coursier.io/docs/cli-overview
function download_coursier() {
  if [[ -f $COURSIER_CLI ]]; then return 0; fi

  if [[ -z $(command -v curl) ]]; then
    echo "cURL is not installed, cannot download coursier" >&2
    exit 1
  fi

  echo "Downloading coursier $COURSIER_VERSION ..." >&2
  curl --progress-bar --location --output "$COURSIER_CLI" "$COURSIER_URL"
  chmod +x "$COURSIER_CLI"
}

# Downloads scalafmt so we can run it from the CLI
# https://scalameta.org/scalafmt/docs/installation.html#coursier
function download_scalafmt() {
  # check version, if not what we expect halt
  if [[ -f $SCALAFMT_CLI ]]; then
    OLD_SCALAFMT_VERSION=$($SCALAFMT_CLI --version)
    if [[ $OLD_SCALAFMT_VERSION == "scalafmt $SCALAFMT_VERSION" ]]; then
      return 0
    else
      echo "scalafmt exists but is a different version ($OLD_SCALAFMT_VERSION)" >&2
      exit 1
    fi
  else
    echo "scalafmt $OLD_SCALAFMT_VERSION does not exist, needs to download" >&2
  fi

  download_coursier

  echo "Downloading scalafmt $SCALAFMT_VERSION using coursier ..." >&2
  $COURSIER_CLI bootstrap org.scalameta:scalafmt-cli_2.12:"$SCALAFMT_VERSION" \
    --standalone \
    --repository sonatype:snapshots \
    --force \
    --output "$SCALAFMT_CLI" \
    --main org.scalafmt.cli.Cli

  # final version check
  if [[ $($SCALAFMT_CLI --version) != "scalafmt $SCALAFMT_VERSION" ]]; then
    echo "scalafmt $SCALAFMT_VERSION did not download correctly" >&2
    rm -f "$SCALAFMT_CLI".broken && mv "$SCALAFMT_CLI" "$SCALAFMT_CLI".broken
    exit 1
  fi
}

# Executes scalafmt for the config file defined in "CONF_FILE"
function run_scalafmt() {
  # If there are no files to process, exit
  if [[ -z $FILES ]]; then return 0; fi

  local CONF_FILE_PATH="$CONF_FOLDER"/"$CONF_NAME"
  if [[ ! -f $CONF_FILE_PATH ]]; then
    echo "Invalid conf name supplied: $CONF_FILE_PATH" >&2
    exit 1
  fi

  # Copy scalafmt config to app directory
  REPO_CONF_FILE=$(git rev-parse --show-toplevel)"/.scalafmt.conf"
  if [[ $COPY_CONF == true && -f "$REPO_CONF_FILE" && $(diff "$CONF_FILE_PATH" "$REPO_CONF_FILE") ]]; then
    cp -f "$CONF_FILE_PATH" "$REPO_CONF_FILE"
  fi

  download_scalafmt

  $SCALAFMT_CLI -c "$CONF_FILE_PATH" -i -f $FILES
}

while (("$#")); do
  case "$1" in
    --conf-name=*)
      CONF_NAME=$(echo "$1" | cut -d '=' -f 2)
      if [[ $1 != *.conf ]]; then
        CONF_NAME="$CONF_NAME.conf"
      fi
      ;;
    --no-copy-conf*)
      COPY_CONF=false
      ;;
    -*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      if [[ ! -f $1 ]]; then
        echo "Invalid arg specified: $1" >&2
        exit 1
      fi
      if [[ -z "$FILES" ]]; then
        FILES=$1
      else
        FILES="$FILES,$1"
      fi
      ;;
  esac
  shift
done

run_scalafmt
