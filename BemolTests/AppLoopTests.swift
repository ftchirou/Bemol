///
/// AppLoopTests.swift
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
import os
import Testing

@testable import Bemol

@MainActor
struct AppLoopTests {
  @Test
  func didLoad() async throws {
    let notePlayer = MockNotePlayer()
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(notePlayer: notePlayer, practiceManager: practiceManager)
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didLoad)

    #expect(nextState.isLoading == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(notePlayer.isPrepareToPlayCalled == true)
    await #expect(practiceManager.isPrepareToPracticeCalled == true)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didLoad`")
      return
    }
  }

  @Test
  func didLoadLevelSuccessfully() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadLevel(.success(makeLevel(id: 42)))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.level?.id == 42)
    #expect(nextState.hasError == false)
    #expect(nextState.error == nil)
    #expect(nextState.question == nil)
    #expect(nextState.answer == nil)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == true)
    #expect(nextState.currentTip == nil)
    #expect(nextState.accuracy == 0)
    #expect(nextState.accuracyPerNote.isEmpty == true)

    #expect(effect == nil)
  }

  @Test
  func didLoadLevelFails() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadLevel(.failure(MockError.error))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }

  @Test
  func didPressHomeButton() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didPressHomeButton)

    #expect(nextState.isLoading == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isMoveToFirstLevelCalled == true)
    await #expect(practiceManager.isMoveToNextLevelCalled == false)
    await #expect(practiceManager.isMoveToPreviousLevelCalled == false)
    await #expect(practiceManager.isMoveToRandomLevelCalled == false)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didPressHomeButton`")
      return
    }
  }

  @Test
  func didPressRandomLevelButton() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didPressRandomButton)

    #expect(nextState.isLoading == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isMoveToRandomLevelCalled == true)
    await #expect(practiceManager.isMoveToNextLevelCalled == false)
    await #expect(practiceManager.isMoveToPreviousLevelCalled == false)
    await #expect(practiceManager.isMoveToFirstLevelCalled == false)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didPressRandomLevelButton`")
      return
    }
  }

  @Test
  func didPressPreviousLevelButton() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didPressPreviousLevelButton)

    #expect(nextState.isLoading == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isMoveToPreviousLevelCalled == true)
    await #expect(practiceManager.isMoveToNextLevelCalled == false)
    await #expect(practiceManager.isMoveToFirstLevelCalled == false)
    await #expect(practiceManager.isMoveToRandomLevelCalled == false)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didPressPreviousLevelButton`")
      return
    }
  }

  @Test
  func didPressNextLevelButton() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didPressNextLevelButton)

    #expect(nextState.isLoading == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isMoveToNextLevelCalled == true)
    await #expect(practiceManager.isMoveToFirstLevelCalled == false)
    await #expect(practiceManager.isMoveToPreviousLevelCalled == false)
    await #expect(practiceManager.isMoveToRandomLevelCalled == false)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didPressNextLevelButton`")
      return
    }
  }

  @Test
  func didPressConfigureLevelButton() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressConfigureLevelButton
    )

    #expect(nextState.isLevelEditorVisible == true)
    #expect(effect == nil)
  }

  @Test
  func didPressStartStopButtonWhenNotPracticing() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState(isPracticing: false)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressStartStopLevelButton
    )

    #expect(nextState.isPracticing == true)
    #expect(nextState.highlightedNote == nil)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isStartSessionCalled == true)
    await #expect(practiceManager.isStopSessionCalled == false)

    guard case .didStartSession = action else {
      Issue.record("expected next action to be `didStartSession` after `didPressStartButton`")
      return
    }
  }

  @Test
  func didPressStartStopButtonWhenPracticing() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState(isPracticing: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressStartStopLevelButton
    )

    #expect(nextState.isPracticing == false)
    #expect(nextState.highlightedNote == nil)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isStopSessionCalled == true)
    await #expect(practiceManager.isStartSessionCalled == false)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didPressStopButton`")
      return
    }
  }

  @Test
  func didStartSessionSuccessfully() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let session = makeSession()
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didStartSession(.success(session))
    )

    let startedSession = try #require(nextState.session)

    #expect(nextState.isLoading == false)
    #expect(startedSession.timestamp == session.timestamp)
    #expect(nextState.correctIdentifications == 0)
    #expect(nextState.questionsCount == 0)
    #expect(nextState.accuracy == 0)
    #expect(nextState.accuracyPerNote.isEmpty == true)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isMoveToNextQuestionCalled == true)

    guard case .didLoadQuestion = action else {
      Issue.record("expected next action to be `didLoadQuestion` after `didStartSession`")
      return
    }
  }

  @Test
  func didStartSessionPopulatesStats() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let session = Session(
      timestamp: 1000,
      score: [
        Note(name: .c, octave: 1): (4, 2),
        Note(name: .d, octave: 1): (3, 0),
        Note(name: .e, octave: 1): (0, 8),
        Note(name: .f, octave: 1): (4, 1),
        Note(name: .g, octave: 1): (0, 0),
        Note(name: .c, octave: 2): (2, 1),
      ]
    )
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didStartSession(.success(session))
    )

    let startedSession = try #require(nextState.session)

    #expect(nextState.isLoading == false)
    #expect(startedSession.timestamp == session.timestamp)
    #expect(nextState.correctIdentifications == 13)
    #expect(nextState.questionsCount == 25)
    #expect(Int(nextState.accuracy * 100) == 52)
    #expect(Int((nextState.accuracyPerNote[Note(name: .c, octave: 1)] ?? 0) * 100) == 66)
    #expect(Int((nextState.accuracyPerNote[Note(name: .d, octave: 1)] ?? 0) * 100) == 100)
    #expect(Int((nextState.accuracyPerNote[Note(name: .e, octave: 1)] ?? 0) * 100) == 0)
    #expect(Int((nextState.accuracyPerNote[Note(name: .f, octave: 1)] ?? 0) * 100) == 80)
    #expect(nextState.accuracyPerNote[Note(name: .g, octave: 1)] == nil)
    #expect(Int((nextState.accuracyPerNote[Note(name: .c, octave: 2)] ?? 0) * 100) == 66)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isMoveToNextQuestionCalled == true)

    guard case .didLoadQuestion = action else {
      Issue.record("expected next action to be `didLoadQuestion` after `didStartSession`")
      return
    }
  }

  @Test
  func didLogRightAnswerUpdatesStats() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let session = Session(
      timestamp: 1000,
      score: [
        Note(name: .c, octave: 1): (4, 2),
        Note(name: .d, octave: 1): (3, 0),
        Note(name: .e, octave: 1): (0, 8),
        Note(name: .f, octave: 1): (4, 1),
        Note(name: .g, octave: 1): (0, 0),
        Note(name: .c, octave: 2): (2, 1),
      ]
    )
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLogRightAnswer(.success(session))
    )

    let startedSession = try #require(nextState.session)

    #expect(nextState.isLoading == false)
    #expect(startedSession.timestamp == session.timestamp)
    #expect(nextState.correctIdentifications == 13)
    #expect(nextState.questionsCount == 25)
    #expect(Int(nextState.accuracy * 100) == 52)
    #expect(Int((nextState.accuracyPerNote[Note(name: .c, octave: 1)] ?? 0) * 100) == 66)
    #expect(Int((nextState.accuracyPerNote[Note(name: .d, octave: 1)] ?? 0) * 100) == 100)
    #expect(Int((nextState.accuracyPerNote[Note(name: .e, octave: 1)] ?? 0) * 100) == 0)
    #expect(Int((nextState.accuracyPerNote[Note(name: .f, octave: 1)] ?? 0) * 100) == 80)
    #expect(nextState.accuracyPerNote[Note(name: .g, octave: 1)] == nil)
    #expect(Int((nextState.accuracyPerNote[Note(name: .c, octave: 2)] ?? 0) * 100) == 66)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isMoveToNextQuestionCalled == true)

    guard case .didLoadQuestion = action else {
      Issue.record("expected next action to be `didLoadQuestion` after `didStartSession`")
      return
    }
  }

  @Test
  func didLogWrongAnswerUpdatesStats() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let session = Session(
      timestamp: 1000,
      score: [
        Note(name: .c, octave: 1): (4, 2),
        Note(name: .d, octave: 1): (3, 0),
        Note(name: .e, octave: 1): (0, 8),
        Note(name: .f, octave: 1): (4, 1),
        Note(name: .g, octave: 1): (0, 0),
        Note(name: .c, octave: 2): (2, 1),
      ]
    )
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLogWrongAnswer(.success(session))
    )

    let startedSession = try #require(nextState.session)

    #expect(nextState.isLoading == false)
    #expect(startedSession.timestamp == session.timestamp)
    #expect(nextState.correctIdentifications == 13)
    #expect(nextState.questionsCount == 25)
    #expect(Int(nextState.accuracy * 100) == 52)
    #expect(Int((nextState.accuracyPerNote[Note(name: .c, octave: 1)] ?? 0) * 100) == 66)
    #expect(Int((nextState.accuracyPerNote[Note(name: .d, octave: 1)] ?? 0) * 100) == 100)
    #expect(Int((nextState.accuracyPerNote[Note(name: .e, octave: 1)] ?? 0) * 100) == 0)
    #expect(Int((nextState.accuracyPerNote[Note(name: .f, octave: 1)] ?? 0) * 100) == 80)
    #expect(nextState.accuracyPerNote[Note(name: .g, octave: 1)] == nil)
    #expect(Int((nextState.accuracyPerNote[Note(name: .c, octave: 2)] ?? 0) * 100) == 66)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == true)

    #expect(effect == nil)
  }

  @Test
  func didStartSessionFails() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didStartSession(.failure(MockError.error))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }

  @Test
  func didPressRepeatQuestionButton() async throws {
    let notePlayer = MockNotePlayer()
    let environment = makeAppEnvironment(notePlayer: notePlayer)
    let state = AppState(isPracticing: true, level: makeLevel(id: 1), question: makeQuestion())
    let loop = AppLoop(environment: environment, initialState: state)


    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressRepeatQuestionButton
    )

    #expect(nextState.isInteractionEnabled == false)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(notePlayer.isPlayNoteCalled == true)
    await #expect(notePlayer.isPlayCadenceCalled == true)

    guard case .didPlayCadence = action else {
      Issue.record("expected next action to be `didPlayCadence` after `didPressRepeatButton`")
      return
    }
  }

  @Test
  func didPressAccuracyRing() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressAccuracyRing
    )

    #expect(nextState.isAccuracyScreenVisible == true)
    #expect(nextState.isLevelEditorVisible == false)
    #expect(effect == nil)
  }

  @Test
  func didPressNoteWhenNotPracticing() async throws {
    let notePlayer = MockNotePlayer()
    let environment = makeAppEnvironment(notePlayer: notePlayer)
    let state = AppState(isPracticing: false)
    let loop = AppLoop(environment: environment, initialState: state)
    let note = Note(name: .d, octave: 1)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressNote(note)
    )

    let highlightedNote = try #require(nextState.highlightedNote)

    #expect(highlightedNote == (note, .amber))

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(notePlayer.isPlayNoteCalled == true)
    await #expect(notePlayer.isPlayCadenceCalled == false)

    #expect(action == nil)
  }

  @Test
  func didPressNoteWhenPracticingAndNoteIsCorrect() async throws {
    let environment = makeAppEnvironment()
    let note = Note(name: .d, octave: 1)
    let state = AppState(
      isPracticing: true,
      level: makeLevel(id: 42),
      question: makeQuestion(answer: note, resolution: [note])
    )

    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressNote(note)
    )

    let highlightedNote = try #require(nextState.highlightedNote)

    #expect(highlightedNote == (note, .systemGreen))
    #expect(nextState.answer == note)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    guard case .didPlayNoteInResolution = action else {
      Issue.record("expected next action to be `didPlayNoteInResolution` after `right answer` but was \(String(describing: action))")
      return
    }
  }

  @Test
  func didPressNoteWhenPracticingAndNoteIsWrong() async throws {
    let notePlayer = MockNotePlayer()
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(notePlayer: notePlayer, practiceManager: practiceManager)
    let note = Note(name: .d, octave: 1)
    let wrongNote = Note(name: .c, octave: 2)
    let state = AppState(
      isPracticing: true,
      level: makeLevel(id: 42),
      question: makeQuestion(answer: note, resolution: [note])
    )

    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressNote(wrongNote)
    )

    let highlightedNote = try #require(nextState.highlightedNote)

    #expect(highlightedNote == (wrongNote, .systemRed))
    #expect(nextState.answer == wrongNote)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(notePlayer.isPlayNoteCalled == true)
    await #expect(practiceManager.isLogWrongAnswerCalled == true)

    guard case .didLogWrongAnswer = action else {
      Issue.record("expected next action to be `didPlayNoteInResolution` after `right answer` but was \(String(describing: action))")
      return
    }
  }

  @Test
  func didReleaseNote() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isPracticing: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (_, effect) = loop.nextState(
      currentState: state,
      action: .didReleaseNote(Note(name: .f, octave: 2))
    )

    #expect(effect == nil)
  }

  @Test
  func didDismissLevelEditor() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLevelEditorVisible: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didDismissLevelEditor
    )

    #expect(nextState.isLevelEditorVisible == false)
    #expect(effect == nil)
  }

  @Test
  func didDismissAccuracyScreen() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isAccuracyScreenVisible: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didDismissAccuracyScreen
    )

    #expect(nextState.isAccuracyScreenVisible == false)
    #expect(effect == nil)
  }

  @Test
  func didSelectNotes() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let level = makeLevel(id: 42)
    let state = AppState(level: level)
    let notes = [
      Note(name: .d, octave: 1),
      Note(name: .eFlat, octave: 2),
    ]
    let loop = AppLoop(environment: environment, initialState: state)

    let (_, effect) = loop.nextState(
      currentState: state,
      action: .didSelectNotes(notes)
    )

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isUseTemporaryLevelCalled == true)

    let temporaryLevel =  await practiceManager.getTemporaryLevel()

    #expect(temporaryLevel?.notes ?? [] == notes)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didSelectNotes`")
      return
    }
  }

  @Test
  func didSelectNotesDoesNotUpdateLevelIfNotesHaveNotChanged() async throws {
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(practiceManager: practiceManager)
    let notes = [
      Note(name: .d, octave: 1),
      Note(name: .eFlat, octave: 2),
    ]
    let level = makeLevel(id: 42, notes: notes)
    let state = AppState(level: level)
    let loop = AppLoop(environment: environment, initialState: state)

    let (_, effect) = loop.nextState(
      currentState: state,
      action: .didSelectNotes(notes)
    )

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isUseTemporaryLevelCalled == false)

    let temporaryLevel =  await practiceManager.getTemporaryLevel()

    #expect(temporaryLevel == nil)

    guard case .didLoadLevel = action else {
      Issue.record("expected next action to be `didLoadLevel` after `didSelectNotes`")
      return
    }
  }

  @Test
  func didLoadQuestionSuccessfully() async throws {
    let notePlayer = MockNotePlayer()
    let environment = makeAppEnvironment(notePlayer: notePlayer)
    let question = makeQuestion(answer: Note(name: .c, octave: 1))
    let state = AppState(isLoading: true, level: makeLevel(id: 42))
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadQuestion(.success(question))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == false)
    #expect(nextState.error == nil)
    #expect(nextState.question?.id ?? UUID() == question.id)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == false)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(notePlayer.isPlayCadenceCalled == true)
    await #expect(notePlayer.isPlayNoteCalled == true)

    guard case .didPlayCadence = action else {
      Issue.record("expected next action to be `didPlayCadence` after `didLoadQuestion`")
      return
    }
  }

  @Test
  func didPlayCadenceSuccessfully() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isInteractionEnabled: false)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPlayCadence(.success(()))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == false)
    #expect(nextState.error == nil)
    #expect(nextState.isInteractionEnabled == true)
    #expect(effect == nil)
  }

  @Test
  func didPlayNoteInResolution() async throws {
    let notePlayer = MockNotePlayer()
    let environment = makeAppEnvironment(notePlayer: notePlayer)
    let resolution: Resolution = [
      Note(name: .d, octave: 1),
      Note(name: .c, octave: 1)
    ]
    let question = makeQuestion(answer: Note(name: .d, octave: 1), resolution: resolution)
    let state = AppState(
      level: makeLevel(id: 42),
      session: makeSession(),
      question: question,
      currentlyPlayingResolution: resolution
    )
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPlayNoteInResolution(.success(()))
    )

    let highlightedNote = try #require(nextState.highlightedNote)

    #expect(highlightedNote == (Note(name: .d, octave: 1), .systemGreen))
    #expect(nextState.currentlyPlayingResolution == [Note(name: .c, octave: 1)])

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(notePlayer.isPlayNoteCalled == true)
    await #expect(notePlayer.isPlayCadenceCalled == false)

    let playedNote = await notePlayer.playedNote

    #expect(playedNote?.name == .d)
    #expect(playedNote?.octave == 1)

    guard case .didPlayNoteInResolution = action else {
      Issue.record("expected next action to be `didPlayNoteInResolution`")
      return
    }
  }

  @Test
  func didPlayLastNoteInResolution() async throws {
    let notePlayer = MockNotePlayer()
    let practiceManager = MockPracticeManager()
    let environment = makeAppEnvironment(notePlayer: notePlayer, practiceManager: practiceManager)
    let resolution: Resolution = []
    let question = makeQuestion(answer: Note(name: .d, octave: 1), resolution: resolution)
    let state = AppState(
      level: makeLevel(id: 42),
      session: makeSession(),
      question: question,
      currentlyPlayingResolution: resolution
    )
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPlayNoteInResolution(.success(()))
    )

    #expect(nextState.highlightedNote == nil)
    #expect(nextState.currentlyPlayingResolution.isEmpty == true)

    let task = Task {
      try await effect?.run()
    }

    let action = try await task.value

    await #expect(practiceManager.isLogCorrectAnswerCalled == true)
    await #expect(notePlayer.isPlayNoteCalled == false)
    await #expect(notePlayer.isPlayCadenceCalled == false)

    guard case .didLogRightAnswer = action else {
      Issue.record("expected next action to be `didLogRightAnswer` after resolution")
      return
    }
  }

  @Test
  func didLoadQuestionFails() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadQuestion(.failure(MockError.error))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }

  @Test
  func didLogRightAnswerFails() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLogRightAnswer(.failure(MockError.error))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }

  @Test
  func didLogWrongAnswerFails() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLogWrongAnswer(.failure(MockError.error))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }

  @Test
  func didPlayCadenceFails() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPlayCadence(.failure(MockError.error))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }

  @Test
  func didPlayNoteInResolutionFails() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPlayNoteInResolution(.failure(MockError.error))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }

  @Test
  func didLoadLevelWhenUserHasNotYetSeenTips() async throws {
    let preferences = MockPreferences()
    preferences.setValue(false, for: .userHasSeenOnboardingPrefKey)

    let tips = [
      Tip(target: .startStopButton, title: "title-1", message: "message-1", actionTitle: "next"),
      Tip(target: .keyboard, title: "title-2", message: "message-2", actionTitle: "done"),
    ]
    let tipProvider = MockTipProvider(tips: tips)

    let environment = makeAppEnvironment(tipProvider: tipProvider, preferences: preferences)
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadLevel(.success(makeLevel(id: 42)))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.level?.id == 42)
    #expect(nextState.hasError == false)
    #expect(nextState.error == nil)
    #expect(nextState.question == nil)
    #expect(nextState.answer == nil)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == false)
    #expect(nextState.currentTip == tips[0])
    #expect(nextState.accuracy == 0)
    #expect(nextState.accuracyPerNote.isEmpty == true)

    #expect(effect == nil)
  }

  @Test
  func didLoadLevelWhenUserHasAlreadySeenTips() async throws {
    let preferences = MockPreferences()
    preferences.setValue(true, for: .userHasSeenOnboardingPrefKey)

    let tips = [
      Tip(target: .startStopButton, title: "title-1", message: "message-1", actionTitle: "next"),
      Tip(target: .keyboard, title: "title-2", message: "message-2", actionTitle: "done"),
    ]
    let tipProvider = MockTipProvider(tips: tips)

    let environment = makeAppEnvironment(tipProvider: tipProvider, preferences: preferences)
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadLevel(.success(makeLevel(id: 42)))
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.level?.id == 42)
    #expect(nextState.hasError == false)
    #expect(nextState.error == nil)
    #expect(nextState.question == nil)
    #expect(nextState.answer == nil)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == true)
    #expect(nextState.currentTip == nil)
    #expect(nextState.accuracy == 0)
    #expect(nextState.accuracyPerNote.isEmpty == true)

    #expect(effect == nil)
  }

  @Test
  func didDismissTip() async throws {
    let preferences = MockPreferences()
    preferences.setValue(false, for: .userHasSeenOnboardingPrefKey)

    let tips = [
      Tip(target: .startStopButton, title: "title-1", message: "message-1", actionTitle: "next"),
      Tip(target: .keyboard, title: "title-2", message: "message-2", actionTitle: "done"),
    ]
    let tipProvider = MockTipProvider(tips: tips)

    let environment = makeAppEnvironment(tipProvider: tipProvider, preferences: preferences)
    let state = AppState(currentTip: tipProvider.nextTip())
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didDismissTip
    )

    #expect(nextState.isInteractionEnabled == false)
    #expect(nextState.currentTip == tips[1])
    #expect(preferences.value(for: .userHasSeenOnboardingPrefKey) == false)
    #expect(effect == nil)
  }

  @Test
  func didDismissLastTip() async throws {
    let preferences = MockPreferences()
    preferences.setValue(false, for: .userHasSeenOnboardingPrefKey)

    let tips = [
      Tip(target: .startStopButton, title: "title-1", message: "message-1", actionTitle: "next"),
      Tip(target: .keyboard, title: "title-2", message: "message-2", actionTitle: "done"),
    ]
    let tipProvider = MockTipProvider(tips: tips)
    let _ = tipProvider.nextTip()

    let environment = makeAppEnvironment(tipProvider: tipProvider, preferences: preferences)
    let state = AppState(currentTip: tipProvider.nextTip())
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didDismissTip
    )

    #expect(nextState.isInteractionEnabled == true)
    #expect(nextState.currentTip == nil)
    #expect(preferences.value(for: .userHasSeenOnboardingPrefKey) == true)
    #expect(effect == nil)
  }

  // MARK: - Private Helpers

  private func makeAppEnvironment(
    notePlayer: NotePlayer = MockNotePlayer(),
    practiceManager: PracticeManager = MockPracticeManager(),
    tipProvider: TipProvider = MockTipProvider(),
    preferences: Preferences = MockPreferences(),
    logger: Logger = Logger()
  ) -> AppEnvironment {
    AppEnvironment(
      notePlayer: notePlayer,
      practiceManager: practiceManager,
      tipProvider: tipProvider,
      preferences: preferences,
      logger: logger
    )
  }
}

// MARK: - Mocks

// MARK: - MockNotePlayer

private actor MockNotePlayer: NotePlayer {
  var isPrepareToPlayCalled = false
  var isPlayNoteCalled = false
  var isPlayCadenceCalled = false
  var playedNote: Note?

  func prepareToPlay() async throws {
    isPrepareToPlayCalled = true
  }
  
  func playNote(_ note: Note) async throws {
    isPlayNoteCalled = true
    playedNote = note
  }

  func playCadence(_ cadence: Cadence) async throws {
    isPlayCadenceCalled = true
  }

  func getPlayedNote() async -> Note? {
    playedNote
  }
}

// MARK: - MockPracticeManager

private actor MockPracticeManager: PracticeManager {
  var isPrepareToPracticeCalled = false
  var isMoveToFirstLevelCalled = false
  var isMoveToNextLevelCalled = false
  var isMoveToPreviousLevelCalled = false
  var isMoveToRandomLevelCalled = false
  var isStartSessionCalled = false
  var isStopSessionCalled = false
  var isMoveToNextQuestionCalled = false
  var isLogCorrectAnswerCalled = false
  var isLogWrongAnswerCalled = false
  var isUseTemporaryLevelCalled = false
  var temporaryLevel: Level? = nil
  var cursor = 0

  func prepareToPractice() async throws {
    isPrepareToPracticeCalled = true
  }
  
  func moveToPreviousLevel() async throws -> Level {
    isMoveToPreviousLevelCalled = true
    cursor -= 1
    return makeLevel(id: cursor)
  }

  func moveToNextLevel() async throws -> Level {
    isMoveToNextLevelCalled = true
    cursor += 1
    return makeLevel(id: cursor)
  }

  func moveToRandomLevel() async throws -> Level {
    isMoveToRandomLevelCalled = true
    cursor = (1...10).randomElement() ?? 1
    return makeLevel(id: cursor)
  }

  func moveToFirstLevel() async throws -> Level {
    isMoveToFirstLevelCalled = true
    cursor = 1
    return makeLevel(id: cursor)
  }

  func startSession() async throws -> Session {
    isStartSessionCalled = true
    return makeSession()
  }

  func stopCurrentSession() async throws -> Level {
    isStopSessionCalled = true
    return makeLevel(id: cursor)
  }

  func moveToNextQuestion() async throws -> Question {
    isMoveToNextQuestionCalled = true
    return makeQuestion()
  }

  func logCorrectAnswer(
    _ note: Bemol.Note,
    for question: Bemol.Question
  ) async throws -> Session {
    isLogCorrectAnswerCalled = true
    return makeSession()
  }

  func logWrongAnswer(
    _ note: Note,
    for question: Question
  ) async throws -> Session {
    isLogWrongAnswerCalled = true
    return makeSession()
  }

  func useTemporaryLevel(level: Level) async throws -> Level {
    isUseTemporaryLevelCalled = true
    temporaryLevel = level
    return level
  }

  func getTemporaryLevel() async -> Level? {
    temporaryLevel
  }
}

// MARK: - MockTipProvider

private final class MockTipProvider: TipProvider {
  let tips: [Tip]
  var index = -1

  init(tips: [Tip] = []) {
    self.tips = tips
  }

  func nextTip() -> Tip? {
    if index + 1 < tips.count {
      index += 1
      return tips[index]
    }

    return nil
  }
}

// MARK: - MockPreferences

private final class MockPreferences: Preferences {
  var values: [String: Any] = [:]

  func value(for key: String) -> Int? {
    values[key] as? Int
  }
  
  func setValue(_ value: Int, for key: String) {
    values[key] = value
  }
  
  func value(for key: String) -> Bool {
    (values[key] as? Bool) ?? false
  }
  
  func setValue(_ value: Bool, for key: String) {
    values[key] = value
  }
}

// MARK: - MockError

private enum MockError: Error {
  case error
}

// MARK: -

fileprivate func makeLevel(
  id: Int,
  key: NoteName = .c,
  isMajor: Bool = false,
  isChromatic: Bool = false,
  notes: [Note] = [],
  cadence: Cadence = Cadence(voices: [], roots: [], movement: []),
  spansMultipleOctaves: Bool = false,
  range: NoteRange = .firstHalfOfOctave,
  sessions: [Session] = []
) -> Level {
  Level(
    id: id,
    key: key,
    isMajor: isMajor,
    isChromatic: isChromatic,
    notes: notes,
    cadence: cadence,
    spansMultipleOctaves: spansMultipleOctaves,
    range: range,
    sessions: sessions
  )
}

fileprivate func makeSession() -> Session {
  Session(timestamp: Date.now.timeIntervalSince1970, score: [:])
}

fileprivate func makeQuestion(
  answer: Note = Note(name: .dFlat, octave: 1),
  resolution: Resolution = []
) -> Question {
  Question(answer: answer, resolution: resolution)
}
