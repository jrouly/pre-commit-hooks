#!/bin/bash -u
# Enforces that any ScalaTests that use timeouts also use IntegrationPatience so that tests are not flaky.

EXIT_CODE=0 # Mutated to 1 if naughty.

for FILE in "$@"; do
    PATIENCE_SUBCLASS=$(grep -o -E '(extends|with)\s+(Waiters|Eventually|Conductors|ScalaFutures)' $FILE)
    USES_PATIENCE=$?

    if test "$USES_PATIENCE" = "0" && ! grep -E '(extends|with)\s+(IntegrationPatience)' $FILE > /dev/null; then
        echo "$FILE $PATIENCE_SUBCLASS"
        EXIT_CODE=1
    fi
done

if [[ $EXIT_CODE != 0 ]]; then
    echo "These files use timeouts but do not include 'with IntegrationPatience'."
    echo "Jenkins is slower and often hits the timeouts resulting in flaky test runs."
    echo "There is a way to extend this globally in sbt, but it doesn't work in IntelliJ."
    echo "For now, adding 'with IntegrationPatience' on every test is the best way."
    echo
fi

exit $EXIT_CODE
