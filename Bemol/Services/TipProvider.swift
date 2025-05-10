///
/// TipProvider.swift
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

protocol TipProvider {
  func nextTip() -> Tip?
}

// MARK: - OnboardingTipProvider

final class OnboardingTipProvider: TipProvider {
  private var index = -1

  func nextTip() -> Tip? {
    if index + 1 < tips.count {
      index += 1
      return tips[index]
    }

    return nil
  }

  private var tips =  [
    Tip(
      target: .startStopButton,
      title: String(localized: "tip.howItWorks.title"),
      message: String(localized: "tip.howItWorks.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .startStopButton,
      title: String(localized: "tip.howItWorks.title"),
      message: String(localized: "tip.howItWorks.content.1"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .startStopButton,
      title: String(localized: "tip.howItWorks.title"),
      message: String(localized: "tip.howItWorks.content.2"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .keyboard,
      title: String(localized: "tip.keyboard.title"),
      message: String(localized: "tip.keyboard.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .titleView,
      title: String(localized: "tip.currentLevel.title"),
      message: String(localized: "tip.currentLevel.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .nextButton,
      title: String(localized: "tip.nextLevel.title"),
      message: String(localized: "tip.nextLevel.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .previousButton,
      title: String(localized: "tip.previousLevel.title"),
      message: String(localized: "tip.previousLevel.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .randomButton,
      title: String(localized: "tip.randomLevel.title"),
      message: String(localized: "tip.randomLevel.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .homeButton,
      title: String(localized: "tip.firstLevel.title"),
      message: String(localized: "tip.firstLevel.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .configureLevelButton,
      title: String(localized: "tip.configureLevel.title"),
      message: String(localized: "tip.configureLevel.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .accuracyRing,
      title: String(localized: "tip.accuracyRing.title"),
      message: String(localized: "tip.accuracyRing.content"),
      actionTitle: String(localized: "tip.next")
    ),
    Tip(
      target: .startStopButton,
      title: String(localized: "tip.getStarted.title"),
      message: String(localized: "tip.getStarted.content"),
      actionTitle: String(localized: "tip.getStarted.button")
    ),
  ]
}
