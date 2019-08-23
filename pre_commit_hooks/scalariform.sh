#!/bin/bash -eu

DIR=$( cd $( dirname "${BASH_SOURCE[0]}") && pwd )

CONF_FOLDER="$DIR/scalariform/templates"
CONF_NAME="default.properties"

### START OF HACK ###
# If the template is a file present on the system, then it's likely to
# NOT be the first of the filename list (meaning the user passed a
# template instead of --conf-name). If this is true, use the given
# argument as the --conf-name argument.
#
# NOTE: This is only here for backwards compatibility. We should start
#       using --conf-name in the future and deprecate this behavior.
#
# TODO: Remove this code at some point
if [[ $1 != *.properties ]]
then
  ARG1="$1.properties"
else
  ARG1="$1"
fi
if [ -f "$CONF_FOLDER/$ARG1" ]
then
  YELLOW='[33;7m'
  OFF='[m'
  echo "
${YELLOW}WARN: Please use '--conf-name=$1' to supply the template in your .pre-commit-config.yaml under the scalariform section.
      (Supplying the template as the first argument to the script is deprecated)${OFF}
"
  CONF_NAME="$ARG1"
  shift
fi
### END OF HACK ###

# Parse args for files and conf name
FILES=""
# Flag to disable copying the conf to the root dir.
COPY_CONF=true
while (( "$#" )); do
  case "$1" in
    --conf-name=*)
      CONF_NAME=$(echo $1 | cut -d '=' -f 2)
      if [[ $1 != *.properties ]]
      then
        CONF_NAME="$CONF_NAME.properties"
      fi
      ;;
    --no-copy-conf*)
      COPY_CONF=false
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
        FILES="$FILES $1"
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

CONF_FILE="$CONF_FOLDER/$CONF_NAME"

if [[ ! -f $CONF_FILE ]]
then
  echo "Invalid conf name supplied: $CONF_NAME"
  exit 1
fi

# Copy scalafmt config to app directory
if [[ $COPY_CONF = true ]]; then
  cp -f $CONF_FILE $(git rev-parse --show-toplevel)/.scalariform.properties
fi

java -jar "$DIR/scalariform/scalariform-0.2.10.jar" \
    --encoding="UTF-8" \
    --preferenceFile="$CONF_FILE" \
    $FILES
