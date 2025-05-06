///
/// Preferences.swift
/// Bemol
///
/// Copyright 2025 Faiçal Tchirou
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
///
///

import Foundation

protocol Preferences {
  func value(for key: String) -> Int?
  func setValue(_ value: Int, for key: String)

  func value(for key: String) -> Bool
  func setValue(_ value: Bool, for key: String)
}

// MARK: -

extension UserDefaults: Preferences {
  func value(for key: String) -> Int? {
    self.value(forKey: key) as? Int
  }

  func setValue(_ value: Int, for key: String) {
    self.setValue(value, forKey: key)
  }

  func value(for key: String) -> Bool {
    self.value(forKey: key) as? Bool ?? false
  }

  func setValue(_ value: Bool, for key: String) {
    self.setValue(value, forKey: key)
  }
}
