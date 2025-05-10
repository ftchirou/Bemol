///
/// Tip.swift
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

struct Tip: Equatable {
  enum Target {
    case titleView
    case startStopButton
    case repeatButton
    case previousButton
    case nextButton
    case randomButton
    case homeButton
    case accuracyRing
    case configureLevelButton
    case keyboard
  }

  let target: Target
  let title: String
  let message: String
  let actionTitle: String

  init(target: Target, title: String, message: String, actionTitle: String) {
    self.target = target
    self.title = title
    self.message = message
    self.actionTitle = actionTitle
  }
}

// MARK: - TipHandler

@MainActor
protocol TipHandler {
  func handle(_ tip: Tip)
}
