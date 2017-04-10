#!/bin/bash -eu

DIR=$( cd $( dirname "${BASH_SOURCE[0]}") && pwd )

COMMA_SEP_FILES=$(echo "$@" | sed -Ee 's/ +/\,/g')

java -jar "${DIR}/scalafmt/scalafmt-0.6.8.jar" -i -f $COMMA_SEP_FILES
