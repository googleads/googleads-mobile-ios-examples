#!/bin/bash
# Script to build projects within java and kotlin subdirectories matching $REGEX variable,
#  using build.sh script.

set -eo pipefail

# An array that holds the google3 path to each example app
EXAMPLE_APPS_PATHS_ARRAY=()

while read -r line; do
  app_path=$(dirname "${line}");
  EXAMPLE_APPS_PATHS_ARRAY+=("${app_path#./}");
done < <(find . -name Podfile -type f -d | grep -E "${REGEX}")

for example_app_path in "${EXAMPLE_APPS_PATHS_ARRAY[@]}"
do
  CHANGES="$(git --no-pager diff --name-only "${COMMIT_RANGE}")";
  echo "Project dir: ${example_app_path}";
  if [[ -n "$(grep -E "(${example_app_path}|\.github\/workflows)" <<< "${CHANGES}")" ]]; then
    echo "Building for ${example_app_path}";
    example_name=$(echo "${example_app_path}" | xargs -I{} basename {});
    echo "::set-output name=building_app::Pod install for App (${example_name})";
    pushd "${example_app_path}";
    pod install --no-repo-update;
    echo "::set-output name=building_app::Building App (${example_name})";
    eval "xcodebuild -workspace ${example_name}.xcworkspace -scheme ${example_name} -sdk iphonesimulator -arch x86_64 | xcpretty";
    popd;
  fi
done
