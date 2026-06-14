///
/// AppAction.swift
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

enum AppAction {
  // MARK: - Lifecycle Actions

  case didLoad

  // MARK: - Tip Actions

  case didDismissTip

  // MARK: - NavBar Actions

  case didPressHomeButton
  case didPressRandomButton
  case didPressPreviousLevelButton
  case didPressNextLevelButton
  case didPressConfigureLevelButton
  case didPressStartStopLevelButton
  case didPressRepeatQuestionButton
  case didPressAccuracyRing

  // MARK: - Keyboard Actions

  case didPressNote(Note)
  case didReleaseNote(Note)

  // MARK: - Modal Actions

  case didDismissAccuracyScreen
  case didDismissLevelEditor
  case didSelectNotes([Note])

  // MARK: - Practice Actions

  case didLoadLevel(Level)
  case didStartSession(Session)
  case didLoadQuestion(Question)
  case didLogRightAnswer(Session)
  case didLogWrongAnswer(Session)
  case didPlayNoteInResolution
  case didPlayCadence

  // MARK: - Errors

  case errorOccurred(any Error)
}

// MARK: - CustomStringConvertible

extension AppAction: CustomStringConvertible {
  var description: String {
    switch self {
    case .didLoad:
      "✅  didLoad"
    case .didDismissTip:
      "💡 didDismissTip"
    case .didPressHomeButton:
      "👆 didPressHome"
    case .didPressRandomButton:
      "👆 didPressRandomLevel"
    case .didPressPreviousLevelButton:
      "👆 didPressPreviousLevel"
    case .didPressNextLevelButton:
      "👆 didPressNextLevel"
    case .didPressConfigureLevelButton:
      "👆 didPressConfigureLevel"
    case .didPressStartStopLevelButton:
      "👆 didPressStartStop"
    case .didPressRepeatQuestionButton:
      "👆 didPressRepeat"
    case .didPressAccuracyRing:
      "👆 didPressAccuracyRing"
    case .didPressNote(let note):
      "🎹 didPressNote - \(note.name.letter) (\(note.octave))"
    case .didReleaseNote(let note):
      "🎹 didReleaseNote - \(note.name.letter) (\(note.octave))"
    case .didDismissAccuracyScreen:
      "👆 didDismissAccuracyView"
    case .didDismissLevelEditor:
      "👆 didDismissLevelEditor"
    case .didSelectNotes(let notes):
      "☑️ didSelectNotes \(notes.map { $0.name.letter })"
    case .didLoadLevel(let level):
      "✅ didLoadLevel - \(level.id) - \(level.title)"
    case .didStartSession(let session):
      "✅ didStartSession at \(session.timestamp)"
    case .didLoadQuestion(let question):
      "✅ didLoadQuestion - \(question.id) - \(question.answer.name.letter)"
    case .didLogRightAnswer(let session):
      "👏 didLogRightAnswer in session started at \(session.timestamp)"
    case .didLogWrongAnswer(let session):
      "😅 didLogWrongAnswer in session started at \(session.timestamp)"
    case .didPlayNoteInResolution:
      "🎵 didPlayNoteInResolution"
    case .didPlayCadence:
      "🎶 didPlayCadence"
    case .errorOccurred(let error):
      "❌ errorOccurred - \(error.localizedDescription)"
    }
  }
}
