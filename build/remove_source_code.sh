#!/bin/sh

export SRC_DIR="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
export IOS_APP_DIR="${SRC_DIR}"
export IOS_APP_FRAMEWORK_SOURCE_DIR="${IOS_APP_DIR}/IdentityIntegrationApp"
export PROJECT_FILE="${IOS_APP_FRAMEWORK_SOURCE_DIR}/IdentityIntegrationApp.xcodeproj/project.pbxproj"

export PROJECT_NAME="Identity"
export FRAMEWORK_SOURCE_DIR="${IOS_APP_FRAMEWORK_SOURCE_DIR}/${PROJECT_NAME}"

rm -rf "${FRAMEWORK_SOURCE_DIR}"

