#!/bin/bash

# make_ios_app.sh
# Bemol
#
# Copyright 2025 Faiçal Tchirou
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


# Usage: ./make_ios_app.sh <marketing_version> <build_version>.
#
set -e

cd "$(dirname "$0")" || exit 1
cd .. || exit 1

export_path="./Artifacts/iOS"

trap "rm -rf $export_path" EXIT

if [ $# -lt 2 ]; then
    echo "Missing one or more arguments!"
    echo "Usage: ./upload_ios_to_testflight.sh <marketing_version> <build_version>"
    exit 1
fi

if [[ -z "${APPLE_ID}" ]]; then
    echo "APPLE_ID not set!"
    exit 1
fi

if [[ -z "${APP_STORE_CONNECT_API_KEY}" ]]; then
    echo "APP_STORE_CONNECT_API_KEY not set!"
    exit 1
fi

if [[ -z "${APP_STORE_CONNECT_API_ISSUER}" ]]; then
    echo "APP_STORE_CONNECT_API_ISSUER not set!"
    exit 1
fi

rm -rf $export_path
mkdir -p $export_path

marketing_version=$1
build_version=$2
archive_path="$export_path/Bemol.xcarchive"
ipa_path="$export_path/Bemol.ipa"
export_options_plist_path="./iOS/TestFlightExportOptions.plist"
authentication_key_path=$(realpath ./iOS/private_keys/AuthKey_"${APP_STORE_CONNECT_API_KEY}".p8)

echo "Setting the marketing version to $marketing_version ..."
sed -i -E "s/MARKETING_VERSION.*/MARKETING_VERSION = $marketing_version/g" \
          ./iOS/Configurations/Versioning.xcconfig

echo "Setting the build version to $build_version ..."
sed -i -E "s/CURRENT_PROJECT_VERSION.*/CURRENT_PROJECT_VERSION = $build_version/g" \
          ./iOS/Configurations/Versioning.xcconfig

if [ -e ./iOS/Configurations/Versioning.xcconfig-E ]; then
  rm ./iOS/Configurations/Versioning.xcconfig-E
fi

echo "Archiving ..."
xcodebuild -project Bemol.xcodeproj \
           -scheme Bemol.iOS \
           -xcconfig ./iOS/Configurations/Release.xcconfig \
           -allowProvisioningUpdates \
           -configuration Release \
           -archivePath $archive_path \
           -authenticationKeyPath "$authentication_key_path" \
           -authenticationKeyID "$APP_STORE_CONNECT_API_KEY" \
           -authenticationKeyIssuerID "$APP_STORE_CONNECT_API_ISSUER" \
           archive

echo "Exporting ..."
xcodebuild -exportArchive \
           -allowProvisioningUpdates \
           -archivePath $archive_path \
           -exportPath $export_path \
           -exportOptionsPlist $export_options_plist_path \
           -authenticationKeyPath "$authentication_key_path" \
           -authenticationKeyID "$APP_STORE_CONNECT_API_KEY" \
           -authenticationKeyIssuerID "$APP_STORE_CONNECT_API_ISSUER"

echo "Validating ..."
xcrun altool --validate-app \
             --file $ipa_path \
             --type ios \
             --apiKey "$APP_STORE_CONNECT_API_KEY" \
             --apiIssuer "$APP_STORE_CONNECT_API_ISSUER" \
             --p8-file-path "$authentication_key_path"

echo "Uploading to TestFlight ..."
xcrun altool --upload-package $ipa_path \
             --type ios \
             --bundle-version "$build_version" \
             --bundle-short-version-string "$marketing_version" \
             --apple-id "$APPLE_ID" \
             --bundle-id com.tchirou.apps.bemol.ios \
             --apiKey "$APP_STORE_CONNECT_API_KEY" \
             --apiIssuer "$APP_STORE_CONNECT_API_ISSUER" \
             --p8-file-path "$authentication_key_path"

echo "Done ✅"
