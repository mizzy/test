#!/bin/bash

pattern=$1

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [[ "$CURRENT_BRANCH" == "master" || "$CURRENT_BRANCH" == "develop" ]]; then
  SOURCE_TARGET="HEAD^"
  DESTINATION_TARGET="HEAD"
else
  SOURCE_TARGET="origin/${GITHUB_BASE_REF}"
   DESTINATION_TARGET="HEAD"
fi

changed_files=$(git diff $SOURCE_TARGET $DESTINATION_TARGET --name-only --no-color | grep -e "$pattern" || :)

# Remove empty lines and lines start with `./`
changed_files=$(echo "$changed_files" | grep -v -e '^\s*$' | sed -e 's/^\.\///g')

echo "$changed_files"
