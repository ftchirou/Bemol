#!/bin/bash

# test.sh
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
#

set -e

artifacts_path=./Artifacts/Tests
result_bundle_path=$artifacts_path/test-results.xcresult

rm -rf $result_bundle_path
rm -rf $artifacts_path
mkdir -p $artifacts_path

xcodebuild test -project Bemol.xcodeproj \
                -scheme Bemol.macOS \
                -testPlan Bemol \
                -destination 'platform=macOS' \
                -enableCodeCoverage YES \
                -resultBundlePath $result_bundle_path
