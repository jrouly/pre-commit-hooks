#!/bin/sh
#
# Don't commit focused tests. Use this as a pre-commit hook and the commit won't succeed if you have staged changes
# that contain `fdescribe`, `fcontext`, `fit`, `fspecify` or `fexample`
# Taken from https://gist.github.com/DerLobi/d938ac7dc422145f85e6
#

STATUS=0

function findFocusedTests(){
    local FOCUSED_TESTS=$(git diff --staged -G"^\s*$1\s*\(" --name-only | wc -l)
    if [ $FOCUSED_TESTS -gt 0 ]; then
      echo "You forgot to remove a $1 in the following files:"
      git diff --staged --name-only -G"^\s*$1\("
      echo ""
      STATUS=1
    fi
}

findFocusedTests "fdescribe"
findFocusedTests "fcontext"
findFocusedTests "fit"
findFocusedTests "fspecify"
findFocusedTests "fexample"

exit $STATUS
