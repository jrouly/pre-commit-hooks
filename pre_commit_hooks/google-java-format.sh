#!/bin/bash -eu

DIR=$( cd $( dirname "${BASH_SOURCE[0]}") && pwd )

FILES=${@:1}

java -jar "$DIR/google-java-format/google-java-format-1.3-all-deps.jar" $FILES
