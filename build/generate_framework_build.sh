#!/bin/sh

export SRC_DIR="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
export IOS_APP_DIR="${SRC_DIR}"
export IOS_APP_FRAMEWORK_SOURCE_DIR="${IOS_APP_DIR}/IdentityIntegrationApp"
export PROJECT_FILE="${IOS_APP_FRAMEWORK_SOURCE_DIR}/IdentityIntegrationApp.xcodeproj/project.pbxproj"

export PROJECT_NAME="Identity"
export FRAMEWORK_SOURCE_DIR="${IOS_APP_FRAMEWORK_SOURCE_DIR}/${PROJECT_NAME}"

# set framework folder name
FRAMEWORK_FOLDER_NAME="${PROJECT_NAME}_XCFramework"
# set framework name or read it from project by this variable
FRAMEWORK_NAME="${PROJECT_NAME}"
#xcframework path
FRAMEWORK_PATH="${IOS_APP_FRAMEWORK_SOURCE_DIR}/${FRAMEWORK_NAME}.xcframework"
# set path for iOS simulator archive
SIMULATOR_ARCHIVE_PATH="${FRAMEWORK_SOURCE_DIR}/${FRAMEWORK_FOLDER_NAME}/simulator.xcarchive"
# set path for iOS device archive
IOS_DEVICE_ARCHIVE_PATH="${FRAMEWORK_SOURCE_DIR}/${FRAMEWORK_FOLDER_NAME}/iOS.xcarchive"
rm -rf "${FRAMEWORK_SOURCE_DIR}/${FRAMEWORK_FOLDER_NAME}"
rm -rf "${FRAMEWORK_PATH}"

echo "Deleted ${FRAMEWORK_FOLDER_NAME}"

mkdir "${FRAMEWORK_FOLDER_NAME}"

echo "Created ${FRAMEWORK_FOLDER_NAME}"
echo "Archiving ${FRAMEWORK_NAME}"
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS Simulator" -archivePath "${SIMULATOR_ARCHIVE_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS" -archivePath "${IOS_DEVICE_ARCHIVE_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
#Creating XCFramework
xcodebuild -create-xcframework -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -framework ${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -output "${FRAMEWORK_PATH}"
rm -rf "${SIMULATOR_ARCHIVE_PATH}"
rm -rf "${IOS_DEVICE_ARCHIVE_PATH}"

