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

enum PreferenceKey: String {
  case userHasSeenOnboarding = "user.has.seen.onboarding"
  case latestPracticeCursor = "practice.level.cursor"
}

protocol Preferences {
  func value(for key: PreferenceKey) -> Int?
  func setValue(_ value: Int, for key: PreferenceKey)

  func value(for key: PreferenceKey) -> Bool
  func setValue(_ value: Bool, for key: PreferenceKey)
}

// MARK: - UserDefaults

extension UserDefaults: Preferences {
  func value(for key: PreferenceKey) -> Int? {
    self.value(forKey: key.rawValue) as? Int
  }

  func setValue(_ value: Int, for key: PreferenceKey) {
    self.setValue(value, forKey: key.rawValue)
  }

  func value(for key: PreferenceKey) -> Bool {
    self.value(forKey: key.rawValue) as? Bool ?? false
  }

  func setValue(_ value: Bool, for key: PreferenceKey) {
    self.setValue(value, forKey: key.rawValue)
  }
}
