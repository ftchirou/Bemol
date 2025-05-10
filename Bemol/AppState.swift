///
/// AppState.swift
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
import UIKit

struct AppState {
  var isLoading: Bool = false
  var isPracticing: Bool = false
  var level: Level? = nil
  var baseLevel: Level? = nil
  var session: Session? = nil
  var question: Question? = nil
  var answer: Note? = nil
  var questionsCount: Int = 0
  var correctIdentifications: Int = 0
  var accuracy: Float = 0.0
  var accuracyPerNote: [Note: Double] = [:]
  var isLevelEditorVisible: Bool = false
  var isAccuracyScreenVisible: Bool = false
  var highlightedNote: (Note, UIColor)? = nil
  var hasError: Bool = false
  var isInteractionEnabled: Bool = false
  var currentlyPlayingResolution: [Note] = []
  var error: Error? = nil
  var currentTip: Tip? = nil
}

extension AppState {
  var mainScreenState: MainScreenState {
    var title = level.flatMap { AttributedString($0.title) }
    if let octaveRange = title?.range(of: "8..") {
      title?[octaveRange].foregroundColor = UIColor.systemGreen
    }

    return MainScreenState(
      isLoading: isLoading,
      key: level?.key ?? .c,
      isPreviousButtonEnabled: !isPracticing && isInteractionEnabled,
      isNextButtonEnabled: !isPracticing && isInteractionEnabled,
      title: title,
      isConfigureButtonEnabled: !isPracticing && isInteractionEnabled,
      isStartStopButtonEnabled: isInteractionEnabled,
      startStopButtonMode: isPracticing ? .stop : .start,
      isRepeatButtonHidden: !isPracticing,
      isRepeatButtonEnabled: isInteractionEnabled,
      isScoreLabelHidden: !isPracticing,
      scoreText: scoreText,
      scoreAccessibilityText: scoreAccessibilityText,
      accuracy: accuracy,
      isAccuracyRingEnabled: isInteractionEnabled,
      accuracyRingAccessibilityText: accuracyRingAccessibilityText,
      isKeyboardEnabled: isInteractionEnabled,
      activeNotes: level?.notes ?? [],
      highlightedNote: highlightedNote,
      tip: currentTip
    )
  }

  var levelEditorScreenState: LevelEditorScreenState {
    LevelEditorScreenState(
      key: level?.key ?? .c,
      allNotes: baseLevel?.notes ?? [],
      selectedNotes: level?.notes ?? []
    )
  }

  var accuracyScreenState: AccuracyScreenState {
    AccuracyScreenState(
      context: session == nil ? .level : .session,
      key: level?.key ?? .c,
      accuracyPerNote: accuracyPerNote,
      activeNotes: level?.notes ?? []
    )
  }

  private var scoreText: AttributedString {
    if questionsCount <= 0 {
      return AttributedString()
    }

    var correctAnswers = AttributedString("\(correctIdentifications)")
    correctAnswers.foregroundColor = .systemGreen

    var wrongAnswers = AttributedString("\(questionsCount - correctIdentifications)")
    wrongAnswers.foregroundColor = .systemRed

    var totalAnswers = AttributedString("\(questionsCount)")
    totalAnswers.foregroundColor = .systemTeal

    return correctAnswers + " · " + wrongAnswers + " · " + totalAnswers
  }

  private var scoreAccessibilityText: String? {
    if questionsCount <= 0 {
      return nil
    }

    return String(format: String(localized: "score"), correctIdentifications, questionsCount)
  }

  private var accuracyRingAccessibilityText: String? {
    let accuracy = Int(self.accuracy * 100)

    if session != nil {
      return String(format: String(localized: "sessionAccuracyRingText"), accuracy)
    }

    return String(format: String(localized: "levelAccuracyRingText"), accuracy)
  }
}
