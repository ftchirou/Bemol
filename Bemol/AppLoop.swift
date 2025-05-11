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

struct AppLoopDelegate {
  let didUpdateState: (AppState) -> Void
}

@MainActor
final class AppLoop {
  private let environment: AppEnvironment
  private(set) var state: AppState

  var delegate: AppLoopDelegate?

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
        if let action = try? await effect.run() {
          self.dispatch(action)
        }
      }
    }
  }

  func nextState(currentState: AppState, action: AppAction) -> (AppState, AppEffect<AppAction?>?) {
    var nextState = currentState

    switch action {
    // MARK: - Lifecycle Actions

    case .didLoad:
      nextState.isLoading = true

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }

          try await self.environment
            .notePlayer
            .prepareToPlay()

          try await self.environment
            .practiceManager
            .prepareToPractice()

          return try await self.environment
            .practiceManager
            .moveToNextLevel()
        }.mapTo(AppAction.didLoadLevel)
      )

    // MARK: - Onboarding Actions

    case .didDismissTip:
      nextState.currentTip = environment.tipProvider.nextTip()
      nextState.isInteractionEnabled = nextState.currentTip == nil

      if nextState.currentTip == nil {
        environment.preferences.setValue(true, for: .userHasSeenOnboardingPrefKey)
      }

      return (nextState, nil)

    // MARK: - NavBar Actions

    case .didPressHomeButton:
      nextState.isLoading = true

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }
          return try await self.environment.practiceManager.moveToFirstLevel()
        }.mapTo(AppAction.didLoadLevel)
      )

    case .didPressRandomButton:
      nextState.isLoading = true

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }
          return try await self.environment.practiceManager.moveToRandomLevel()
        }.mapTo(AppAction.didLoadLevel)
      )

    case .didPressPreviousLevelButton:
      nextState.isLoading = true

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }
          return try await self.environment.practiceManager.moveToPreviousLevel()
        }.mapTo(AppAction.didLoadLevel)
      )

    case .didPressNextLevelButton:
      nextState.isLoading = true

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }
          return try await self.environment.practiceManager.moveToNextLevel()
        }.mapTo(AppAction.didLoadLevel)
      )

    case .didPressConfigureLevelButton:
      nextState.isLevelEditorVisible = true

      return (nextState, nil)

    case .didPressStartStopLevelButton:
      nextState.isPracticing.toggle()
      nextState.highlightedNote = nil

      if nextState.isPracticing {
        return (
          nextState,
          AppEffect { [weak self] in
            guard let self else { throw AppError.unexpected }
            return try await self.environment
              .practiceManager
              .startSession()
          }.mapTo(AppAction.didStartSession)
        )
      }

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }

          return try await self.environment
            .practiceManager
            .stopCurrentSession()
        }.mapTo(AppAction.didLoadLevel)
      )

    case .didPressRepeatQuestionButton:
      guard currentState.isPracticing else { return (nextState, nil) }

      nextState.isInteractionEnabled = false

      return (
        nextState,
        AppEffect { [weak self] in
          guard
            let self,
            let level = nextState.level,
            let question = nextState.question
          else {
            throw AppError.unexpected
          }

          let cadence: () = try await self.environment
            .notePlayer
            .playCadence(level.cadence)

          try await self.environment
            .notePlayer
            .playNote(question.answer)

          return cadence
        }.mapTo(AppAction.didPlayCadence)
      )

    case .didPressAccuracyRing:
      nextState.isAccuracyScreenVisible = true

      return (nextState, nil)

    // MARK: - Keyboard Actions

    case .didPressNote(let note):
      guard currentState.isPracticing else {
        nextState.highlightedNote = (note, .amber)
  
        return (
          nextState,
          AppEffect { [weak self] in
            guard let self else { throw AppError.unexpected }

            try await self.environment
              .notePlayer
              .playNote(note)

            return nil
          }
        )
      }

      guard let level = currentState.level, let question = currentState.question else {
        return (nextState, nil)
      }

      let isCorrect = level.spansMultipleOctaves
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
      return (
        nextState,
        AppEffect { [weak self] in
          guard let self, let level = currentState.level else { throw AppError.unexpected }

          let newLevel = if Set(notes) == Set(level.notes) {
            level
          } else if let baseLevel = currentState.baseLevel, Set(notes) == Set(baseLevel.notes) {
            baseLevel
          } else {
            level.withNotes(notes)
          }

          return try await self.environment
            .practiceManager
            .setCurrentLevel(newLevel)
        }.mapTo(AppAction.didLoadLevel)
      )


    // MARK: - Async Actions

    case .didLoadLevel(.success(let level)):
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

      if !environment.preferences.value(for: .userHasSeenOnboardingPrefKey) {
        nextState.currentTip = environment.tipProvider.nextTip()
        nextState.isInteractionEnabled = nextState.currentTip == nil
      }

      return (nextState, nil)

    case .didStartSession(.success(let session)), .didLogRightAnswer(.success(let session)):
      nextState.isLoading = false
      nextState.hasError = false
      nextState.session = session
      nextState.correctIdentifications = session.summary.correct
      nextState.questionsCount = session.summary.correct + session.summary.wrong
      nextState.accuracy = Float(session.summary.average)
      nextState.accuracyPerNote = session.summary.averagePerNote
      nextState.highlightedNote = nil
      nextState.isInteractionEnabled = true

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }

          return try await self.environment.practiceManager.moveToNextQuestion()
        }.mapTo(AppAction.didLoadQuestion)
      )

    case .didLogWrongAnswer(.success(let session)):
      nextState.isLoading = false
      nextState.hasError = false
      nextState.session = session
      nextState.correctIdentifications = session.summary.correct
      nextState.questionsCount = session.summary.correct + session.summary.wrong
      nextState.accuracy = Float(session.summary.average)
      nextState.accuracyPerNote = session.summary.averagePerNote
      nextState.isInteractionEnabled = true

      return (nextState, nil)

    case .didLoadQuestion(.success(let question)):
      nextState.isLoading = false
      nextState.hasError = false
      nextState.question = question
      nextState.highlightedNote = nil
      nextState.isInteractionEnabled = false

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self, let level = currentState.level else { throw AppError.unexpected }
          let cadence: () = try await self.environment
            .notePlayer
            .playCadence(level.cadence)

          try await self.environment
            .notePlayer
            .playNote(question.answer)

          return cadence
        }.mapTo(AppAction.didPlayCadence)
      )

    case .didPlayCadence(.success):
      nextState.isInteractionEnabled = true

      return (nextState, nil)

    case .didPlayNoteInResolution(.success):
      if currentState.currentlyPlayingResolution.isEmpty {
        return (
          nextState,
          AppEffect { [weak self] in
            guard let self, let question = currentState.question else { throw AppError.unexpected }

            return try await self.environment
              .practiceManager
              .logCorrectAnswer(question.answer, for: question)
          }.mapTo(AppAction.didLogRightAnswer)
        )
      }

      let note = currentState.currentlyPlayingResolution[0]

      nextState.highlightedNote = (note, .systemGreen)
      nextState.currentlyPlayingResolution = Array(currentState.currentlyPlayingResolution[1...])

      return (
        nextState,
        AppEffect { [weak self] in
          guard let self else { throw AppError.unexpected }

          return try await self.environment
            .notePlayer
            .playNote(note)
        }.mapTo(AppAction.didPlayNoteInResolution)
      )

    // MARK: - Error States

    case .didLoadLevel(.failure(let error)):
      nextState.error = error
      nextState.isLoading = false
      nextState.hasError = true
      return (nextState, nil)

    case .didStartSession(.failure(let error)):
      nextState.error = error
      nextState.isLoading = false
      nextState.hasError = true
      return (nextState, nil)

    case .didLoadQuestion(.failure(let error)):
      nextState.error = error
      nextState.isLoading = false
      nextState.hasError = true
      return (nextState, nil)

    case .didLogRightAnswer(.failure(let error)):
      nextState.error = error
      nextState.isLoading = false
      nextState.hasError = true
      return (nextState, nil)

    case .didLogWrongAnswer(.failure(let error)):
      nextState.error = error
      nextState.isLoading = false
      nextState.hasError = true
      return (nextState, nil)

    case .didPlayCadence(.failure(let error)):
      nextState.error = error
      nextState.isLoading = false
      nextState.hasError = true
      return (nextState, nil)

    case .didPlayNoteInResolution(.failure(let error)):
      nextState.error = error
      nextState.hasError = true
      return (nextState, nil)
    }
  }

  private func stateForCorrectNotePressed(
    currentState: AppState,
    question: Question,
    note: Note
  ) -> (AppState, AppEffect<AppAction?>?) {
    var nextState = currentState
    nextState.answer = note
    nextState.highlightedNote = (note, .systemGreen)
    nextState.isInteractionEnabled = false
    nextState.currentlyPlayingResolution = currentState.question?.resolution ?? []

    if let note = nextState.currentlyPlayingResolution.first {
      nextState.highlightedNote = (note, .systemGreen)
    }

    return (
      nextState,
      AppEffect {}.mapTo(AppAction.didPlayNoteInResolution)
    )
  }

  private func stateForWrongNotePressed(
    currentState: AppState,
    question: Question,
    note: Note
  ) -> (AppState, AppEffect<AppAction?>?) {
    var nextState = currentState
    nextState.answer = note
    nextState.highlightedNote = (note, .systemRed)
    nextState.isInteractionEnabled = false

    return (
      nextState,
      AppEffect { [weak self] in
        guard
          let self,
          let question = currentState.question
        else {
          throw AppError.unexpected
        }

        try await self.environment
          .notePlayer
          .playNote(note)

        return try await self.environment
          .practiceManager
          .logWrongAnswer(note, for: question)
      }.mapTo(AppAction.didLogWrongAnswer)
    )
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

// MARK: - Preference Keys

extension String {
  static let userHasSeenOnboardingPrefKey = "user.has.seen.onboarding"
}
