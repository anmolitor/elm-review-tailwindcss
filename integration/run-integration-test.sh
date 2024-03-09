#!/bin/bash
set -eu
set -o pipefail

# This is a snapshot/golden test to verify that the postcss - elm-review integration is working as expected.

# Generate the application bundle and emit the review/src/TailwindCss/ClassOrder.elm file.
npm run build
# Initial run should report expected errors
elm-review --report=json | jq -M '.errors[].errors | sort_by(.rule, .region.start.line, .region.start.column)' | diff expected/before.json -
echo "Initial run went as expected."
# Automatically fix all fixable errors
echo 'y' | elm-review --fix-all || true
echo "Fixable errors were fixed."
# reports all errors that are not fixable
elm-review --report=json | jq -M '.errors[].errors | sort_by(.rule, .region.start.line, .region.start.column)' | diff expected/after.json -
echo "Second run went as expected."
# Fixes are what we expected them to be
diff src/Main.elm expected/Main.elm
echo "Fixes were correct."
# Revert changes to src/Main.elm so the test is reproducable
git checkout -- src/Main.elm
# Delete generated class order file
rm review/src/TailwindCss/ClassOrder.elm

