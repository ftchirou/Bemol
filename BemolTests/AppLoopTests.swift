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
import Testing
import UIKit
import os

@testable import Bemol

@MainActor
struct AppLoopTests {
  @Test
  func didLoad() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didLoad)

    #expect(nextState.isLoading == true)
    #expect(effect == .prepareToPractice)
  }

  @Test
  func didLoadLevel() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadLevel(makeLevel(id: 42))
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
  func didPressHomeButton() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didPressHomeButton)

    #expect(nextState.isLoading == true)
    #expect(effect == .loadFirstLevel)
  }

  @Test
  func didPressRandomLevelButton() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didPressRandomButton)

    #expect(nextState.isLoading == true)
    #expect(effect == .loadRandomLevel)
  }

  @Test
  func didPressPreviousLevelButton() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state, action: .didPressPreviousLevelButton)

    #expect(nextState.isLoading == true)
    #expect(effect == .loadPreviousLevel)
  }

  @Test
  func didPressNextLevelButton() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(currentState: state, action: .didPressNextLevelButton)

    #expect(nextState.isLoading == true)
    #expect(effect == .loadNextLevel)
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
    let environment = makeAppEnvironment()
    let state = AppState(isPracticing: false)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressStartStopLevelButton
    )

    #expect(nextState.isPracticing == true)
    #expect(nextState.highlightedNote == nil)
    #expect(effect == .startSession)
  }

  @Test
  func didPressStartStopButtonWhenPracticing() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isPracticing: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressStartStopLevelButton
    )

    #expect(nextState.isPracticing == false)
    #expect(nextState.highlightedNote == nil)
    #expect(effect == .stopSession)
  }

  @Test
  func didStartSession() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let session = makeSession()
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didStartSession(session)
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

    #expect(effect == .loadNextQuestion)
  }

  @Test
  func didStartSessionPopulatesStats() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let session = Session(
      timestamp: 1000,
      score: [
        Note(name: .c, octave: 1): .init(correct: 4, wrong: 2),
        Note(name: .d, octave: 1): .init(correct: 3, wrong: 0),
        Note(name: .e, octave: 1): .init(correct: 0, wrong: 8),
        Note(name: .f, octave: 1): .init(correct: 4, wrong: 1),
        Note(name: .g, octave: 1): .init(correct: 0, wrong: 0),
        Note(name: .c, octave: 2): .init(correct: 2, wrong: 1),
      ]
    )
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didStartSession(session)
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

    #expect(effect == .loadNextQuestion)
  }

  @Test
  func didLogRightAnswerUpdatesStats() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let session = Session(
      timestamp: 1000,
      score: [
        Note(name: .c, octave: 1): .init(correct: 4, wrong: 2),
        Note(name: .d, octave: 1): .init(correct: 3, wrong: 0),
        Note(name: .e, octave: 1): .init(correct: 0, wrong: 8),
        Note(name: .f, octave: 1): .init(correct: 4, wrong: 1),
        Note(name: .g, octave: 1): .init(correct: 0, wrong: 0),
        Note(name: .c, octave: 2): .init(correct: 2, wrong: 1),
      ]
    )
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLogRightAnswer(session)
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

    #expect(effect == .loadNextQuestion)
  }

  @Test
  func didLogWrongAnswerUpdatesStats() async throws {
    let environment = makeAppEnvironment()
    let state = AppState()
    let loop = AppLoop(environment: environment, initialState: state)

    let session = Session(
      timestamp: 1000,
      score: [
        Note(name: .c, octave: 1): .init(correct: 4, wrong: 2),
        Note(name: .d, octave: 1): .init(correct: 3, wrong: 0),
        Note(name: .e, octave: 1): .init(correct: 0, wrong: 8),
        Note(name: .f, octave: 1): .init(correct: 4, wrong: 1),
        Note(name: .g, octave: 1): .init(correct: 0, wrong: 0),
        Note(name: .c, octave: 2): .init(correct: 2, wrong: 1),
      ]
    )
    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLogWrongAnswer(session)
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
  func didPressRepeatQuestionButton() async throws {
    let level = makeLevel(id: 1)
    let question = makeQuestion()
    let environment = makeAppEnvironment()
    let state = AppState(isPracticing: true, level: level, question: question)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressRepeatQuestionButton
    )

    #expect(nextState.isInteractionEnabled == false)
    #expect(effect == .repeatQuestion(level, question))
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
    let environment = makeAppEnvironment()
    let state = AppState(isPracticing: false)
    let loop = AppLoop(environment: environment, initialState: state)
    let note = Note(name: .d, octave: 1)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressNote(note)
    )

    let highlightedNote = try #require(nextState.highlightedNote)

    #expect(highlightedNote == (note, .amber))
    #expect(effect == .playNote(note))
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
    #expect(effect == .playNoteInResolution(nil))
  }

  @Test
  func didPressNoteWhenPracticingAndNoteIsWrong() async throws {
    let environment = makeAppEnvironment()
    let note = Note(name: .d, octave: 1)
    let question = makeQuestion(answer: note, resolution: [note])
    let wrongNote = Note(name: .c, octave: 2)
    let state = AppState(
      isPracticing: true,
      level: makeLevel(id: 42),
      question: question
    )

    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPressNote(wrongNote)
    )

    let highlightedNote = try #require(nextState.highlightedNote)

    #expect(highlightedNote == (wrongNote, .systemRed))
    #expect(nextState.answer == wrongNote)
    #expect(effect == .logWrongAnswer(wrongNote, question))
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
    let environment = makeAppEnvironment()
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

    #expect(effect == .loadLevel(level.withNotes(notes)))
  }

  @Test
  func didSelectNotesDoesNotUpdateLevelIfNotesHaveNotChanged() async throws {
    let environment = makeAppEnvironment()
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

    #expect(effect == nil)
  }

  @Test
  func didLoadQuestion() async throws {
    let environment = makeAppEnvironment()
    let level = makeLevel(id: 42)
    let question = makeQuestion(answer: Note(name: .c, octave: 1))
    let state = AppState(isLoading: true, level: level)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didLoadQuestion(question)
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == false)
    #expect(nextState.error == nil)
    #expect(nextState.question?.id ?? UUID() == question.id)
    #expect(nextState.highlightedNote == nil)
    #expect(nextState.isInteractionEnabled == false)
    #expect(effect == .playCadence(level, question))
  }

  @Test
  func didPlayCadence() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isInteractionEnabled: false)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .didPlayCadence
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == false)
    #expect(nextState.error == nil)
    #expect(nextState.isInteractionEnabled == true)
    #expect(effect == nil)
  }

  @Test
  func didPlayNoteInResolution() async throws {
    let environment = makeAppEnvironment()
    let resolution: Resolution = [
      Note(name: .d, octave: 1),
      Note(name: .c, octave: 1),
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
      action: .didPlayNoteInResolution
    )

    let highlightedNote = try #require(nextState.highlightedNote)

    #expect(highlightedNote == (Note(name: .d, octave: 1), .systemGreen))
    #expect(nextState.currentlyPlayingResolution == [Note(name: .c, octave: 1)])
    #expect(effect == .playNoteInResolution(Note(name: .d, octave: 1)))
  }

  @Test
  func didPlayLastNoteInResolution() async throws {
    let environment = makeAppEnvironment()
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
      action: .didPlayNoteInResolution
    )

    #expect(nextState.highlightedNote == nil)
    #expect(nextState.currentlyPlayingResolution.isEmpty == true)
    #expect(effect == .logRightAnswer(question.answer, question))
  }

  @Test
  func didLoadLevelWhenUserHasNotYetSeenTips() async throws {
    let preferences = MockPreferences()
    preferences.setValue(false, for: .userHasSeenOnboarding)

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
      action: .didLoadLevel(makeLevel(id: 42))
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
    preferences.setValue(true, for: .userHasSeenOnboarding)

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
      action: .didLoadLevel(makeLevel(id: 42))
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
    preferences.setValue(false, for: .userHasSeenOnboarding)

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
    #expect(preferences.value(for: .userHasSeenOnboarding) == false)
    #expect(effect == nil)
  }

  @Test
  func didDismissLastTip() async throws {
    let preferences = MockPreferences()
    preferences.setValue(false, for: .userHasSeenOnboarding)

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
    #expect(preferences.value(for: .userHasSeenOnboarding) == true)
    #expect(effect == nil)
  }

  @Test
  func errorOccurred() async throws {
    let environment = makeAppEnvironment()
    let state = AppState(isLoading: true)
    let loop = AppLoop(environment: environment, initialState: state)

    let (nextState, effect) = loop.nextState(
      currentState: state,
      action: .errorOccurred(MockError.error)
    )

    #expect(nextState.isLoading == false)
    #expect(nextState.hasError == true)
    #expect(nextState.error as? MockError == MockError.error)

    #expect(effect == nil)
  }
}
