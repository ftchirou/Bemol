#!/bin/bash

# make_macos_app.sh
# Bemol
#
# Copyright 2026 Faiçal Tchirou
#
# Bemol is free software: you can redistribute it and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# Bemol is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Foobar.
# If not, see <https://www.gnu.org/licenses/>.

# References
# ==============
#
# Creating Developer ID certificates: https://developer.apple.com/help/account/certificates/create-developer-id-certificates/
# Signing macOS apps for distribution: https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac
# Notarizing macOS apps: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
# Notarization in custom build processes: https://developer.apple.com/documentation/security/customizing-the-notarization-workflow
# Resolving common notarization issues: https://developer.apple.com/documentation/security/resolving-common-notarization-issues

set -e

cd "$(dirname "$0")" || exit 1
cd .. || exit 1

if [ $# -lt 2 ]; then
  echo "Missing one or more arguments!"
  echo "Usage: ./make_macos_app.sh <marketing_version> <build_version>"
fi

if [[ -z "${APP_STORE_CONNECT_API_KEY}" ]]; then
    echo "APP_STORE_CONNECT_API_KEY not set!"
    exit 1
fi

if [[ -z "${APP_STORE_CONNECT_API_ISSUER}" ]]; then
    echo "APP_STORE_CONNECT_API_ISSUER not set!"
    exit 1
fi


export_dir="./Artifacts/macOS"

rm -rf $export_dir
mkdir -p $export_dir

marketing_version=$1
build_version=$2
archive_path="$export_dir/Bemol.xcarchive"
export_options_plist="./macOS/ExportOptions.plist"
authentication_key_path=$(realpath ./macOS/private_keys/AuthKey_"$APP_STORE_CONNECT_API_KEY".p8)

echo "Setting the marketing version to $marketing_version ..."
sed -i -E "s/MARKETING_VERSION.*/MARKETING_VERSION = $marketing_version/g" \
          ./macOS/Configurations/Versioning.xcconfig

echo "Setting the build version to $build_version ..."
sed -i -E "s/CURRENT_PROJECT_VERSION.*/CURRENT_PROJECT_VERSION = $build_version/g" \
          ./macOS/Configurations/Versioning.xcconfig

rm ./macOS/Configurations/Versioning.xcconfig-E

echo "Archiving ..."
xcodebuild -project Bemol.xcodeproj \
           -scheme Bemol.macOS \
           -xcconfig ./macOS/Configurations/Release.xcconfig \
           -configuration Release \
           -archivePath $archive_path \
           -authenticationKeyPath "$authentication_key_path" \
           -authenticationKeyID "$APP_STORE_CONNECT_API_KEY" \
           -authenticationKeyIssuerID "$APP_STORE_CONNECT_API_ISSUER" \
           archive

echo "Exporting ..."
xcodebuild -exportArchive \
           -archivePath $archive_path \
           -exportPath $export_dir \
           -exportOptionsPlist $export_options_plist \
           -authenticationKeyPath "$authentication_key_path" \
           -authenticationKeyID "$APP_STORE_CONNECT_API_KEY" \
           -authenticationKeyIssuerID "$APP_STORE_CONNECT_API_ISSUER"

app_path="$export_dir"/Bemol.app
zip_path="$export_dir"/Bemol.zip

/usr/bin/ditto -c -k --keepParent "$app_path" "$zip_path"

echo "Notarizing ..."

xcrun notarytool store-credentials "notarytool-credentials" \
    --key "$authentication_key_path" \
    --key-id "$APP_STORE_CONNECT_API_KEY" \
    --issuer "$APP_STORE_CONNECT_API_ISSUER"

xcrun notarytool submit $zip_path \
    --keychain-profile "notarytool-credentials" \
    --verbose \
    --wait \
    --timeout 2h \
    --output-format plist > ./Artifacts/macOS/NotarizationResponse.plist

xcrun stapler staple $app_path
rm "$zip_path"
/usr/bin/ditto -c -k --keepParent "$app_path" "$zip_path"

echo "Done."
