///
/// MockPreferences.swift
/// Bemol
///
/// Copyright 2026 Faiçal Tchirou
///
/// Bemol is free software: you can redistribute it and/or modify it under the terms of
/// the GNU General Public License as published by the Free Software Foundation, either version 3
/// of the License, or (at your option) any later version.
///
/// Bemol is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
/// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
/// See the GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License along with Foobar.
/// If not, see <https://www.gnu.org/licenses/>.

import Foundation

@testable import Bemol

final class MockPreferences: Preferences {
  var values: [String: Any] = [:]

  func value(for key: PreferenceKey) -> Int? {
    values[key.rawValue] as? Int
  }

  func setValue(_ value: Int, for key: PreferenceKey) {
    values[key.rawValue] = value
  }

  func value(for key: PreferenceKey) -> Bool {
    (values[key.rawValue] as? Bool) ?? false
  }

  func setValue(_ value: Bool, for key: PreferenceKey) {
    values[key.rawValue] = value
  }
}
