#!/bin/bash -eu

DIR=$( cd $( dirname "${BASH_SOURCE[0]}") && pwd )

FILES=${@:1}
CONFIG="project/scalastyle-config.xml"

# If project is missing scalastyle config, script will use default config
if [ ! -f "project/scalastyle-config.xml" ]; then
  CONFIG="$DIR/scalastyle/configs/default.xml"
fi

java -jar "$DIR/scalastyle/scalastyle_2.12-1.0.0-batch.jar" --config $CONFIG --warnings false $FILES
