#!/bin/sh

export SRC_DIR="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
export BRANCH="Cloud"
export IOS_APP_DIR="${SRC_DIR}"
export IOS_APP_BUILD_SCRIPT_DIR="${IOS_APP_DIR}/build"

#rm -R ~/Library/Developer/Xcode/DerivedData

genrate_info_plist() {
    read -d '' exportOptions << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>method</key>
        <string>app-store</string>
</dict>
</plist>
EOF
    local plist_file="info.plist"
    echo "${exportOptions}" > "${plist_file}"
#    info "************** archive_export_options ${archive_export_options}"
}

genrate_info_plist
xcrun xcodebuild -scheme "IdentityIntegrationApp" -configuration "Release" -archivePath "out/app.xcarchive" archive -allowProvisioningUpdates

xcodebuild -exportArchive -archivePath "out/app.xcarchive" -exportPath "ipa/" -exportOptionsPlist "info.plist" -allowProvisioningUpdates


