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

  // MARK: - Async Actions

  case didLoadLevel(Result<Level, Error>)
  case didStartSession(Result<Session, Error>)
  case didLoadQuestion(Result<Question, Error>)
  case didLogRightAnswer(Result<Session, Error>)
  case didLogWrongAnswer(Result<Session, Error>)

  case didPlayNoteInResolution(Result<Void, Error>)
  case didPlayCadence(Result<Void, Error>)
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


    case .didLoadLevel(.success(let level)):
      "✅ didLoadLevel - \(level.id) - \(level.title)"
    case .didLoadLevel(.failure(let error)):
      "❌ didFailToLoadLevel - \(error.localizedDescription)"

    case .didStartSession(.success(let session)):
      "✅ didStartSession at \(session.timestamp)"
    case .didStartSession(.failure(let error)):
      "❌ didFailToStartSession - \(error.localizedDescription)"

    case .didLoadQuestion(.success(let question)):
      "✅ didLoadQuestion - \(question.id) - \(question.answer.name.letter)"
    case .didLoadQuestion(.failure(let error)):
      "❌ didFailToLoadQuestion - \(error.localizedDescription)"

    case .didLogRightAnswer(.success(let session)):
      "👏 didLogRightAnswer in session started at \(session.timestamp)"
    case .didLogRightAnswer(.failure(let error)):
      "❌ didFailToLogRightAnswer - \(error.localizedDescription)"

    case .didLogWrongAnswer(.success(let session)):
      "😅 didLogWrongAnswer in session started at \(session.timestamp)"
    case .didLogWrongAnswer(.failure(let error)):
      "❌ didFailToLogWrongAnswer - \(error.localizedDescription)"

    case .didPlayNoteInResolution(.success):
      "🎵 didPlayNoteInResolution"
    case .didPlayNoteInResolution(.failure(let error)):
      "❌ didFailToPlayNoteInResolution - \(error.localizedDescription)"

    case .didPlayCadence(.success()):
      "🎶 didPlayCadence"
    case .didPlayCadence(.failure(let error)):
      "❌ didFailToPlayCadence - \(error.localizedDescription)"
    }
  }
}

