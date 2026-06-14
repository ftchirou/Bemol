///
/// AppLoop.swift
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
import os

struct AppLoopDelegate {
  let didUpdateState: (AppState) -> Void
}

@MainActor
final class AppLoop {
  private let environment: AppEnvironment
  private(set) var state: AppState

  var delegate: AppLoopDelegate?

  private lazy var effectHandler = AppEffectHandler(environment: environment)

  init(environment: AppEnvironment, initialState: AppState) {
    self.environment = environment
    self.state = initialState
  }

  func dispatch(_ action: AppAction) {
    environment.logger.log(level: .default, "\(action)")

    let (newState, effect) = nextState(currentState: state, action: action)

    state = newState
    delegate?.didUpdateState(newState)

    if let effect {
      Task {
        if let action = await effectHandler.handleEffect(effect) {
          self.dispatch(action)
        }
      }
    }
  }

  func nextState(currentState: AppState, action: AppAction) -> (AppState, AppEffect?) {
    var nextState = currentState

    switch action {
    // MARK: - Lifecycle Actions

    case .didLoad:
      nextState.isLoading = true

      return (nextState, .prepareToPractice)

    // MARK: - Onboarding Actions

    case .didDismissTip:
      nextState.currentTip = environment.tipProvider.nextTip()
      nextState.isInteractionEnabled = nextState.currentTip == nil

      if nextState.currentTip == nil {
        environment.preferences.setValue(true, for: .userHasSeenOnboarding)
      }

      return (nextState, nil)

    // MARK: - NavBar Actions

    case .didPressHomeButton:
      nextState.isLoading = true

      return (nextState, .loadFirstLevel)

    case .didPressRandomButton:
      nextState.isLoading = true

      return (nextState, .loadRandomLevel)

    case .didPressPreviousLevelButton:
      nextState.isLoading = true

      return (nextState, .loadPreviousLevel)

    case .didPressNextLevelButton:
      nextState.isLoading = true

      return (nextState, .loadNextLevel)

    case .didPressConfigureLevelButton:
      nextState.isLevelEditorVisible = true

      return (nextState, nil)

    case .didPressStartStopLevelButton:
      nextState.isPracticing.toggle()
      nextState.highlightedNote = nil

      if nextState.isPracticing {
        return (nextState, .startSession)
      }

      return (nextState, .stopSession)

    case .didPressRepeatQuestionButton:
      guard
        currentState.isPracticing,
        let level = currentState.level,
        let question = currentState.question
      else { return (nextState, nil) }

      nextState.isInteractionEnabled = false
      return (nextState, .repeatQuestion(level, question))

    case .didPressAccuracyRing:
      nextState.isAccuracyScreenVisible = true

      return (nextState, nil)

    // MARK: - Keyboard Actions

    case .didPressNote(let note):
      guard currentState.isPracticing else {
        nextState.highlightedNote = (note, .amber)
        return (nextState, .playNote(note))
      }

      guard
        let level = currentState.level,
        let question = currentState.question
      else {
        return (nextState, nil)
      }

      let isCorrect =
        level.spansMultipleOctaves
        ? note.name == question.answer.name
        : note == question.answer

      if isCorrect {
        return stateForCorrectNotePressed(
          currentState: currentState,
          question: question,
          note: note
        )
      } else {
        return stateForWrongNotePressed(
          currentState: currentState,
          question: question,
          note: note
        )
      }

    case .didReleaseNote:
      return (nextState, nil)

    // MARK: - Modal Actions

    case .didDismissLevelEditor:
      nextState.isLevelEditorVisible = false

      return (nextState, nil)

    case .didDismissAccuracyScreen:
      nextState.isAccuracyScreenVisible = false

      return (nextState, nil)

    case .didSelectNotes(let notes):
      guard
        let level = currentState.level,
        Set(notes) != Set(level.notes)
      else { return (nextState, nil) }

      let newLevel =
        if let baseLevel = currentState.baseLevel, Set(notes) == Set(baseLevel.notes) {
          baseLevel
        } else {
          level.withNotes(notes)
        }

      return (nextState, .loadLevel(newLevel))

    // MARK: - Async Actions

    case .didLoadLevel(let level):
      nextState.isLoading = false
      nextState.hasError = false
      nextState.level = level
      nextState.accuracy = Float(level.summary.average)
      nextState.accuracyPerNote = level.summary.averagePerNote
      nextState.session = nil
      nextState.question = nil
      nextState.answer = nil
      nextState.highlightedNote = nil
      nextState.isInteractionEnabled = true

      if !level.isCustom {
        nextState.baseLevel = level
      }

      if !environment.preferences.value(for: .userHasSeenOnboarding) {
        nextState.currentTip = environment.tipProvider.nextTip()
        nextState.isInteractionEnabled = nextState.currentTip == nil
      }

      return (nextState, nil)

    case .didStartSession(let session), .didLogRightAnswer(let session):
      nextState.isLoading = false
      nextState.hasError = false
      nextState.session = session
      nextState.correctIdentifications = session.summary.correct
      nextState.questionsCount = session.summary.correct + session.summary.wrong
      nextState.accuracy = Float(session.summary.average)
      nextState.accuracyPerNote = session.summary.averagePerNote
      nextState.highlightedNote = nil
      nextState.isInteractionEnabled = true

      return (nextState, .loadNextQuestion)

    case .didLogWrongAnswer(let session):
      nextState.isLoading = false
      nextState.hasError = false
      nextState.session = session
      nextState.correctIdentifications = session.summary.correct
      nextState.questionsCount = session.summary.correct + session.summary.wrong
      nextState.accuracy = Float(session.summary.average)
      nextState.accuracyPerNote = session.summary.averagePerNote
      nextState.isInteractionEnabled = true

      return (nextState, nil)

    case .didLoadQuestion(let question):
      guard let level = currentState.level else { return (nextState, nil) }

      nextState.isLoading = false
      nextState.hasError = false
      nextState.question = question
      nextState.highlightedNote = nil
      nextState.isInteractionEnabled = false

      return (nextState, .playCadence(level, question))

    case .didPlayCadence:
      nextState.isInteractionEnabled = true

      return (nextState, nil)

    case .didPlayNoteInResolution:
      guard let question = currentState.question else { return (nextState, nil) }

      if currentState.currentlyPlayingResolution.isEmpty {
        return (nextState, .logRightAnswer(question.answer, question))
      }

      let note = currentState.currentlyPlayingResolution[0]

      nextState.highlightedNote = (note, .systemGreen)
      nextState.currentlyPlayingResolution = Array(currentState.currentlyPlayingResolution[1...])

      return (nextState, .playNoteInResolution(note))

    // MARK: - Error States

    case .errorOccurred(let error):
      nextState.error = error
      nextState.isLoading = false
      nextState.hasError = true
      return (nextState, nil)
    }
  }

  private func stateForCorrectNotePressed(
    currentState: AppState,
    question: Question,
    note: Note
  ) -> (AppState, AppEffect?) {
    var nextState = currentState
    nextState.answer = note
    nextState.highlightedNote = (note, .systemGreen)
    nextState.isInteractionEnabled = false
    nextState.currentlyPlayingResolution = currentState.question?.resolution ?? []

    if let note = nextState.currentlyPlayingResolution.first {
      nextState.highlightedNote = (note, .systemGreen)
    }

    return (nextState, .playNoteInResolution(nil))
  }

  private func stateForWrongNotePressed(
    currentState: AppState,
    question: Question,
    note: Note
  ) -> (AppState, AppEffect?) {
    var nextState = currentState
    nextState.answer = note
    nextState.highlightedNote = (note, .systemRed)
    nextState.isInteractionEnabled = false

    return (nextState, .logWrongAnswer(note, question))
  }
}

// MARK: - AppError

enum AppError: Error, LocalizedError {
  case unexpected

  var errorDescription: String? {
    switch self {
    case .unexpected:
      "💀 Something truly unexpected occurred!"
    }
  }
}
