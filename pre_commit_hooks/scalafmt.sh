#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -eu

##############################################################################
# Installs scalafmt and runs it at the command line for the provided files.
#
# Usage:
#   ./scalafmt.sh [--no-copy-conf] [--conf-name=<CONF_NAME>] [file ...]

# - Scalafmt native - https://scalameta.org/scalafmt/docs/installation.html#native-image
##############################################################################

# Check scalafmt/README.md before modifying scalafmt version
SCALAFMT_VERSION=2.0.0

# https://electrictoolbox.com/bash-script-directory/
SCALAFMT_SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
PRE_COMMIT_HOOKS_DIR=$(pushd "$SCALAFMT_SCRIPT_DIR" >/dev/null && pwd && popd >/dev/null)
SCALAFMT_DIR="$PRE_COMMIT_HOOKS_DIR/scalafmt"
CONF_DIR="$SCALAFMT_DIR/conf"
REPO_ROOT_DIR=$(git rev-parse --show-toplevel)
# If running on mac os, use darwin binary, else use linux binary
SCALAFMT_KERNEL=scalafmt-linux
if [ "$(uname)" == "Darwin" ]; then
  SCALAFMT_KERNEL=scalafmt-macos
fi
SCALAFMT_NATIVE="$SCALAFMT_DIR/$SCALAFMT_KERNEL-$SCALAFMT_VERSION"
# -conf-name - configuration file name, default will be overwritten if specified
CONF_NAME=default.conf
# --no-copy-conf - Flag to disable copying the conf to the root of the git clone
COPY_CONF=true
# Comma separated line of ABSOLUTE file names to format
FILES=""

# Checks that scalafmt native CLI exists, and if not, downloads it
# scalafmt native releases began with 2.3.2, this will fail with older versions
# Older versions are pulled from here: https://github.com/mroth/scalafmt-native
# - Scalafmt native CLI - https://scalameta.org/scalafmt/docs/installation.html#native-image
function check_and_download_scalafmt() {
  [[ -f "$SCALAFMT_DIR/scalafmt-macos-$SCALAFMT_VERSION" || -f "$SCALAFMT_DIR/scalafmt-linux-$SCALAFMT_VERSION" ]] && return

  echo "Downloading scalafmt $SCALAFMT_VERSION ..." >&2
  # we don't care about stdout for downloads
  download_scalafmt "macos" > /dev/null
  download_scalafmt "linux" > /dev/null
}

# param kernel: which kernel to
# Downloads scalafmt-native
# param $1: Kernel to download scalafmt-native for, macos or linux
function download_scalafmt() {
  [[ -z $(command -v curl) ]] && (echo "cURL is not installed, cannot download scalafmt" >&2 && exit 1)

  KERNEL=$1
  CWD=$(pwd)
  SCALAFMT_NATIVE_TMP=$(mktemp -d)
  cd $SCALAFMT_NATIVE_TMP
  SCALAFMT_BIN=scalafmt-$KERNEL
  SCALAFMT_ZIP=$SCALAFMT_BIN.zip
  curl --fail --silent -Lo "$SCALAFMT_ZIP" "https://github.com/scalameta/scalafmt/releases/download/v$SCALAFMT_VERSION/$SCALAFMT_ZIP"
  if [ $? != 0 ]; then
    echo "Failed to download scalafmt-native" >&2
    exit 1
  fi
  unzip $SCALAFMT_ZIP
  chmod +x scalafmt
  cp scalafmt $SCALAFMT_DIR/$SCALAFMT_BIN-$SCALAFMT_VERSION
  cd $CWD
  rm -rf $SCALAFMT_NATIVE_TMP
}

# If $COPY_CONF is true this copies all config files from "conf" to $REPO_ROOT_DIR and renames "CONF_FILE" to
# ".scalafmt.conf" so the configs can be used by an IDE plugin
function copy_configs_to_local() {
  [[ $COPY_CONF ]] && return

  # Copy all new/changed  configs to app directory (we don't know which ones will be used via "include" so copy them all
  # we don't try and delete from the repo root because that's too risky to screw up and break something
  for orig_conf_file in "$CONF_DIR"/*; do
    local_conf_file="$REPO_ROOT_DIR/$(basename "$orig_conf_file")"
    if [[ ! -f "$local_conf_file" || $(diff "$orig_conf_file" "$local_conf_file") -ne 0 ]]; then
      cp -f "$orig_conf_file" "$local_conf_file"
    fi
  done

  # rename the SPECIFIED config file as the main one (that's the one the IDE plugin is looking for)
  mv "$REPO_ROOT_DIR/$CONF_NAME" "$REPO_ROOT_DIR/.scalafmt.conf"
}

# Executes scalafmt for the config file defined in "CONF_FILE"
function run_scalafmt() {
  # If there are no files to process, exit
  [[ -z "$FILES" ]] && return

  local CONF_FILE_PATH="$CONF_DIR"/"$CONF_NAME"
  if [[ ! -f "$CONF_FILE_PATH" ]]; then
    echo "Invalid conf name supplied: $CONF_FILE_PATH" >&2
    exit 1
  fi

  copy_configs_to_local || (echo "Failed to copy configs to local " >&2 && exit 1)
  check_and_download_scalafmt || (echo "Failed to find scalafmt" >&2 && exit 1)

  # for HOCON's includes to work we must have all the configs in the current working directory. (I tried putting them
  # in the classpath, even making a custom JAR, and that didn't work. this is the ONLY way I've been able to get
  # HOCON includes to work
  # https://github.com/lightbend/config/blob/master/HOCON.md#includes
  pushd "$CONF_DIR" >/dev/null
  # direct stderr to /dev/null so we don't see useless "Reformatting..." messages
  $SCALAFMT_NATIVE --non-interactive -c "$CONF_NAME" -i -f $FILES >/dev/null
  popd >/dev/null
}

# https://stackoverflow.com/a/21188136/11889
function get_abs_filename() {
  # $1 : relative filename
  filename=$1
  parentdir=$(dirname "${filename}")

  if [ -d "$filename" ]; then
    pushd "$filename" >/dev/null && pwd && popd >/dev/null
  elif [ -d "$parentdir" ]; then
    # I'm not sure how to apply the pushd/popd trick here ...
    echo "$(cd "$parentdir" && pwd)/$(basename "$filename")"
  fi
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
      echo "Error: Unsupported flag $1" >&2 && exit 1
      ;;
    *)
      if [[ ! -f "$1" ]]; then
        echo "Invalid arg specified: $1" >&2 && exit 1
      fi

      NEW_FILE=$(get_abs_filename "$1")
      if [[ -z "$FILES" ]]; then
        FILES=$NEW_FILE
      else
        FILES="$FILES,$NEW_FILE"
      fi
      ;;
  esac
  shift
done

run_scalafmt
