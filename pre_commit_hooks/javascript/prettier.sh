#!/bin/sh
# Execute `prettier` if available.

if [[ -z $(command -v prettier) ]]
then
  echo "prettier is not installed. pre-commit hook cannot run."
  exit 1
else
  prettier --write 'src/**/*.js'
fi
