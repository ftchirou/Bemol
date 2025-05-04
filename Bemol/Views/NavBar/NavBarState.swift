///
/// NavBar.swift
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

import Foundation

struct NavBarState: Equatable {
  enum StartStopMode {
    case start
    case stop
  }

  var isLoading: Bool
  var isPreviousButtonEnabled: Bool
  var isNextButtonEnabled: Bool
  var title: AttributedString?
  var isConfigureButtonEnabled: Bool
  var isStartStopButtonEnabled: Bool
  var startStopButtonMode: StartStopMode
  var isRepeatButtonHidden: Bool
  var isRepeatButtonEnabled: Bool
  var isScoreLabelHidden: Bool
  var scoreText: AttributedString?
  var scoreAccessibilityText: String?
  var accuracy: Float
  var isAccuracyRingEnabled: Bool
  var accuracyRingAccessibilityText: String?

  // Shortcuts!
  var isHomeButtonEnabled: Bool {
    isPreviousButtonEnabled
  }

  var isRandomButtonEnabled: Bool {
    isPreviousButtonEnabled
  }
}
