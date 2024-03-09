set -e

# This is a snapshot/golden test to verify that the postcss - elm-review integration is working as expected.

# Initial run should report expected errors
elm-review --report=json | jq '.errors[].errors' | diff expected/before.json -
# Automatically fix all fixable errors, reports all errors that are not fixable
echo 'y' | elm-review --fix-all --report=json | jq '.errors[].errors' | diff expected/after.json -
# Fixes are what we expected them to be
diff src/Main.elm expected/Main.elm
# Revert changes to src/Main.elm so the test is reproducable
git checkout -- src/Main.elm
# Delete generated class order file
rm review/src/TailwindCss/ClassOrder.elm

