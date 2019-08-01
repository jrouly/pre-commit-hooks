#!/bin/bash -eu

# For each conf, copy ugly templates and format them.
for CONF_FILE in $(find pre_commit_hooks/scalafmt/conf -name '*.conf'); do
    CONF_NAME="$(basename $CONF_FILE .conf)" # => "connect"
    echo "Generating examples for $CONF_NAME..."

    # Copy all the ugly templates to the examples dir.
    # It's okay if there add'l conf-specific files in there. We can format those too.
    EXAMPLE_DIR="pre_commit_hooks/scalafmt-examples/confs/$CONF_NAME"
    mkdir -p "$EXAMPLE_DIR"
    cp -rf pre_commit_hooks/scalafmt-examples/templates/ "$EXAMPLE_DIR"

    # Format them.
    find $EXAMPLE_DIR -type f | xargs pre_commit_hooks/scalafmt.sh --no-copy-conf "--conf-name=$CONF_NAME"
done
