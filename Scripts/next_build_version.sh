#!/bin/bash

# next_build_version.sh
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


# The next build version is simply the current
# total number of commits on 'main'.
#
set -e

commit_count=`git rev-list --full-history --count main`

echo $commit_count
