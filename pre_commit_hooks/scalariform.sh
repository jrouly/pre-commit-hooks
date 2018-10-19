#!/bin/bash

DIR=$( cd $( dirname "${BASH_SOURCE[0]}") && pwd )

TEMPLATE=$1
FILES=${@:2}

# If the template is a file present on the system, then it's likely to
# actually be the first of the filename list (meaning the user passed an
# empty template). If this is true, fall back to the default template.
if [ -e $TEMPLATE ]
then
  FILES=${@:1}
  TEMPLATE="default"
fi

java -jar "$DIR/scalariform/scalariform-0.1.8.jar" --encoding="UTF-8" --preferenceFile="$DIR/scalariform/templates/$TEMPLATE.properties" $FILES