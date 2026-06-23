#!/bin/bash

# next_marketing_version.sh
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


# The marketing version is a concatenation of the
# current year, the current week number, and the total
# number of builds that have already been released during
# the current week + 1.
#
set -e

year=`date +%Y`

week=`date +%V | sed 's/^0*//'`

tags=`git tag -l "$year.$week.*"`

build_number=1

for tag in $tags; do build_number=$((build_number + 1)); done;

echo $year.$week.$build_number
