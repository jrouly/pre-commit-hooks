#!/bin/sh
# Execute `prettier` if available.

if [[ -z $(command -v yarn) ]]
then
  echo "yarn is not installed. pre-commit hook cannot run."
  exit 1
else
  yarn prettier --write 'src/**/*.js'
fi
