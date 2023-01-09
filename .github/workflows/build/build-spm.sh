#!/bin/bash
# Script to build projects within java and kotlin subdirectories matching $REGEX variable,
#  using build.sh script.

set -eo pipefail

CHANGES="$(git --no-pager diff --name-only "${COMMIT_RANGE}")";
echo "Project dir: ${REGEX}";
echo "Building for ${REGEX}";
example_name=$(echo "${REGEX}" | xargs -I{} basename {});
pushd "${REGEX}";
echo "::set-output name=building_app::Building App (${REGEX})";
eval "xcodebuild -project ${example_name}.xcodeproj -scheme ${example_name} -sdk iphonesimulator -arch x86_64 | xcpretty";
popd;
