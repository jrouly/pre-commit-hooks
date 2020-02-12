#!/bin/bash -eu

if [ ! -d "pre_commit_hooks" ]; then
    echo "Cannot find 'pre_commit_hooks' -- this must be run from the root of the 'pre_commit_hooks' checkout" 1>&2
    exit 1
fi
# For each conf, copy ugly templates and format them.
for CONF_FILE in "pre_commit_hooks/scalafmt/conf/"*.conf; do
    CONF_NAME=$(basename "$CONF_FILE" .conf) # => "connect"
    echo "Formatting with configuration $CONF_FILE ..." >&2

    # Copy all the ugly templates to the examples dir.
    # It's okay if there add'l conf-specific files in there. We can format those too.
    OUTPUT_DIR="pre_commit_hooks/scalafmt-examples/confs/$CONF_NAME"
    mkdir -p "$OUTPUT_DIR"
    cp -rf pre_commit_hooks/scalafmt-examples/templates/* "$OUTPUT_DIR"

    # Format them.
    for FILE in "$OUTPUT_DIR"/*; do
        echo "  └ $FILE" >&2
        pre_commit_hooks/scalafmt.sh --no-copy-conf "--conf-name=$CONF_NAME" "./$FILE"
    done
done
