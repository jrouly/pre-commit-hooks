#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# Execute `prettier` if available.
if [[ -z $(command -v prettier) ]]; then
  echo "prettier is not installed. pre-commit hook cannot run." >&2
  exit 1
fi

prettier --write 'src/**/*.+(js|jsx|ts|tsx)'
