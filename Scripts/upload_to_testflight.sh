#!/bin/bash

# upload_to_testflight.sh
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


# Usage: ./upload_to_testflight.sh <marketing_version> <build_version>.
#
set -e

export_path="./Artifacts"

# Clean up on exit.
trap "rm -rf $export_path" EXIT

if [ $# -lt 2 ]; then
    echo "Missing one or more arguments!"
    echo "Usage: ./upload_to_testflight.sh <marketing_version> <build_version>"
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
mkdir $export_path

marketing_version=$1
build_version=$2
archive_path="$export_path/Bemol.xcarchive"
ipa_path="$export_path/Bemol.ipa"
export_options_plist_path="./Resources/TestFlightExportOptions.plist"
authentication_key_path=`realpath ./private_keys/AuthKey_${APP_STORE_CONNECT_API_KEY}.p8`

# Set the marketing version
echo "Setting the marketing version to $marketing_version ..."
sed -i -E "s/MARKETING_VERSION.*/MARKETING_VERSION = $marketing_version/g" \
          ./Configurations/Versioning.xcconfig

# Set the build version
echo "Setting the build version to $build_version ..."
sed -i -E "s/CURRENT_PROJECT_VERSION.*/CURRENT_PROJECT_VERSION = $build_version/g" \
          ./Configurations/Versioning.xcconfig

# Archive Bemol
echo "Archiving ..."
xcodebuild -project Bemol.xcodeproj \
           -scheme Bemol \
           -allowProvisioningUpdates \
           -configuration Release \
           -archivePath $archive_path \
           -authenticationKeyPath $authentication_key_path \
           -authenticationKeyID ${APP_STORE_CONNECT_API_KEY} \
           -authenticationKeyIssuerID ${APP_STORE_CONNECT_API_ISSUER} \
           archive

# Export the archive
echo "Exporting ..."
xcodebuild -exportArchive \
           -allowProvisioningUpdates \
           -archivePath $archive_path \
           -exportPath $export_path \
           -exportOptionsPlist $export_options_plist_path \
           -authenticationKeyPath $authentication_key_path \
           -authenticationKeyID ${APP_STORE_CONNECT_API_KEY} \
           -authenticationKeyIssuerID ${APP_STORE_CONNECT_API_ISSUER}

# Validate the ipa
echo "Validating ..."
xcrun altool --validate-app \
             --file $ipa_path \
             --type ios \
             --apiKey ${APP_STORE_CONNECT_API_KEY} \
             --apiIssuer ${APP_STORE_CONNECT_API_ISSUER}

# Upload to TestFlight
echo "Uploading ..."
xcrun altool --upload-package $ipa_path \
             --type ios \
             --bundle-version $build_version \
             --bundle-short-version-string $marketing_version \
             --apple-id ${APPLE_ID} \
             --bundle-id com.tchirou.apps.bemol \
             --apiKey ${APP_STORE_CONNECT_API_KEY} \
             --apiIssuer ${APP_STORE_CONNECT_API_ISSUER}

echo "Done ✅"
