#!/usr/bin/env bash
# Fails if any module under modules/ has no documentation page.
#
# The "declared in self" filter in sphinxcontrib-nixdomain cannot tell the
# difference between a module that is documented and one that was forgotten:
# an undocumented module is not an error, it is simply absent. This check is
# the only thing that notices.
#
# Every module except the top-level modules/default.nix aggregator is expected
# to have a page, including modules that happen to be named default.nix
# (modules/desktop/default.nix and modules/server/default.nix both are real,
# and both declare options).
#
# Usage: scripts/docs-coverage.sh [repo-root]
set -euo pipefail

cd "${1:-.}"

status=0

while IFS= read -r module; do
  # Page name is the module path relative to modules/, with the extension and
  # any trailing "/default" dropped:
  #   modules/baseline.nix          -> docs/source/modules/baseline.md
  #   modules/users/mkononenko.nix  -> docs/source/modules/users/mkononenko.md
  #   modules/desktop/default.nix   -> docs/source/modules/desktop.md
  # Keying on the path rather than the basename keeps a directory module from
  # colliding with a sibling file of the same name.
  relative="${module#modules/}"
  name="${relative%.nix}"
  name="${name%/default}"
  page="docs/source/modules/${name}.md"

  if [[ ! -f "$page" ]]; then
    printf 'missing documentation: %s has no %s\n' "$module" "$page" >&2
    status=1
  fi
done < <(find modules -name '*.nix' ! -path 'modules/default.nix' | sort)

if ((status == 0)); then
  echo "docs coverage: every module under modules/ has a page under docs/source/modules/"
fi

exit "$status"
