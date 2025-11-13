#!/bin/bash
# Script to build projects within the current directory matching $REGEX
# variable, using CocoaPods or Swift Package Manager.

set -eo pipefail

# Find all unique directories containing an .xcodeproj file matching the REGEX
EXAMPLE_APPS_PATHS_ARRAY=()
while read -r line; do
  APP_PATH=$(dirname "${line#./}")
  EXAMPLE_APPS_PATHS_ARRAY+=("${APP_PATH}");
done < <(find . -name "*.xcodeproj" -type d | grep -E "${REGEX}" | sort -u)

for example_app_path in "${EXAMPLE_APPS_PATHS_ARRAY[@]}"
do
  CHANGES=$(git --no-pager diff --name-only "${COMMIT_RANGE}");
  echo "Project dir: ${example_app_path}";

  if [[ -n $(grep -E "(${example_app_path}|\\.github\\/workflows)" <<< "${CHANGES}") ]]; then
    echo "Building for ${example_app_path}";
    example_name=$(basename "${example_app_path}")
    pushd "${example_app_path}";

    # If Podfile exists, always use the .xcworkspace file.
    if [[ -f "Podfile" ]]; then
      echo "Podfile found. Using CocoaPods workflow for ${example_name}.";
      pod install --no-repo-update;
      echo "Building app ${example_name} with CocoaPods.";
      if ! eval "xcodebuild -workspace ${example_name}.xcworkspace -scheme ${example_name} -sdk iphonesimulator -arch x86_64 | xcpretty"; then
        echo "Build failed for ${example_app_path}."
        exit 1
      fi

    # If no Podfile exists, use the .xcodeproj file.
    elif [[ -d "${example_name}.xcodeproj" ]]; then
      echo "No Podfile found. Using standard .xcodeproj file for ${example_name}.";
      echo "Building app ${example_name}.";
      if ! eval "xcodebuild -project ${example_name}.xcodeproj -scheme ${example_name} -sdk iphonesimulator -arch x86_64 | xcpretty"; then
        echo "Build failed for ${example_app_path}."
        exit 1
      fi

    else
      echo "No Podfile or .xcodeproj found in ${example_app_path}.";
      exit 1
    fi
    popd;
  fi
done
