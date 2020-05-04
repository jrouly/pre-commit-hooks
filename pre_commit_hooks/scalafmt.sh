#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -eu

##############################################################################
# Installs scalafmt and runs it at the command line for the provided files.
#
# Usage:
#   ./scalafmt.sh [--no-copy-conf] [--conf-name=<CONF_NAME>] [file ...]
##############################################################################

SCALAFMT_VERSION=2.5.1

# https://electrictoolbox.com/bash-script-directory/
SCALAFMT_SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
PRE_COMMIT_HOOKS_DIR=$(pushd "$SCALAFMT_SCRIPT_DIR" >/dev/null && pwd && popd >/dev/null)
SCALAFMT_DIR="$PRE_COMMIT_HOOKS_DIR/scalafmt"
CONF_DIR="$SCALAFMT_DIR/conf"
REPO_ROOT_DIR=$(git rev-parse --show-toplevel)
SCALAFMT_CLI="$SCALAFMT_DIR/scalafmt-$SCALAFMT_VERSION"

# -conf-name - configuration file name, default will be overwritten if specified
CONF_NAME=default.conf
# --no-copy-conf - Flag to disable copying the conf to the root of the git clone
COPY_CONF=true
# Comma separated line of ABSOLUTE file names to format
FILES=""

# Checks that scalafmt CLI exists, and if not, downloads it
# - Scalafmt CLI - https://scalameta.org/scalafmt/docs/installation.html#native-image
function check_and_download_scalafmt() {
  [[ -f "$SCALAFMT_CLI" ]] && return

  echo "Downloading scalafmt $SCALAFMT_VERSION ..." >&2
  # redirect to /dev/null because it still prints garbage even with --quiet :(
  curl https://raw.githubusercontent.com/scalameta/scalafmt/master/bin/install-scalafmt-native.sh | \
  bash -s -- $SCALAFMT_VERSION $SCALAFMT_CLI > /dev/null
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
  $SCALAFMT_CLI --non-interactive -c "$CONF_NAME" -i -f $FILES >/dev/null
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
