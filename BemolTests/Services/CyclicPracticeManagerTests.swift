///
/// CyclicPractiveManagerTests.swift
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

@testable import Bemol

struct CyclicPracticeManagerTests {
  @Test
  func logCorrectAnswer() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .c, octave: 1)
    let _ = try await manager.startSession()
    let question = Question(answer: note, resolution: [])

    let updatedSession = try await manager.logCorrectAnswer(note, for: question)

    #expect(updatedSession.score.count == 1)
    #expect(updatedSession.score[note] ?? (0, 0) == (1, 0))
  }

  @Test
  func multipleLogCorrectAnswerForSameNoteIncrementsScoreForDifferentQuestions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .c, octave: 1)
    let _ = try await manager.startSession()
    let question1 = Question(answer: note, resolution: [])
    let question2 = Question(answer: note, resolution: [])
    let question3 = Question(answer: note, resolution: [])

    let _ = try await manager.logCorrectAnswer(note, for: question1)
    let _ = try await manager.logCorrectAnswer(note, for: question2)
    let updatedSession = try await manager.logCorrectAnswer(note, for: question3)

    #expect(updatedSession.score.count == 1)
    #expect(updatedSession.score[note] ?? (0, 0) == (3, 0))
  }

  @Test
  func multipleLogCorrectAnswerForSameNoteDoesNotIncrementScoreForTheSameQuestions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .c, octave: 1)
    let _ = try await manager.startSession()
    let question = Question(answer: note, resolution: [])

    let _ = try await manager.logCorrectAnswer(note, for: question)
    let _ = try await manager.logCorrectAnswer(note, for: question)
    let updatedSession = try await manager.logCorrectAnswer(note, for: question)

    #expect(updatedSession.score.count == 1)
    #expect(updatedSession.score[note] ?? (0, 0) == (1, 0))
  }

  @Test
  func logWrongAnswer() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .c, octave: 1)
    let _ = try await manager.startSession()
    let question = Question(answer: note, resolution: [])

    let updatedSession = try await manager.logWrongAnswer(note, for: question)

    #expect(updatedSession.score.count == 1)
    #expect(updatedSession.score[note] ?? (0, 0) == (0, 1))
  }

  @Test
  func multipleLogWrongAnswerForSameNoteIncrementsScoreForDifferentQuestions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .c, octave: 1)
    let _ = try await manager.startSession()
    let question1 = Question(answer: note, resolution: [])
    let question2 = Question(answer: note, resolution: [])
    let question3 = Question(answer: note, resolution: [])

    let _ = try await manager.logWrongAnswer(note, for: question1)
    let _ = try await manager.logWrongAnswer(note, for: question2)
    let updatedSession = try await manager.logWrongAnswer(note, for: question3)

    #expect(updatedSession.score.count == 1)
    #expect(updatedSession.score[note] ?? (0, 0) == (0, 3))
  }

  @Test
  func multipleLogWrongAnswerForSameNoteDoesNotIncrementScoreForTheSameQuestions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .c, octave: 1)
    let _ = try await manager.startSession()
    let question = Question(answer: note, resolution: [])

    let _ = try await manager.logWrongAnswer(note, for: question)
    let _ = try await manager.logWrongAnswer(note, for: question)
    let updatedSession = try await manager.logWrongAnswer(note, for: question)

    #expect(updatedSession.score.count == 1)
    #expect(updatedSession.score[note] ?? (0, 0) == (0, 1))
  }

  @Test
  func logCorrectAndWrongAnswersForSameNoteForDifferentQuestions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .c, octave: 1)
    let _ = try await manager.startSession()
    let question1 = Question(answer: note, resolution: [])
    let question2 = Question(answer: note, resolution: [])
    let question3 = Question(answer: note, resolution: [])
    let question4 = Question(answer: note, resolution: [])
    let question5 = Question(answer: note, resolution: [])

    let _ = try await manager.logCorrectAnswer(note, for: question1)
    let _ = try await manager.logWrongAnswer(note, for: question2)
    let _ = try await manager.logWrongAnswer(note, for: question3)
    let _ = try await manager.logCorrectAnswer(note, for: question4)
    let updatedSession = try await manager.logCorrectAnswer(note, for: question5)

    #expect(updatedSession.score.count == 1)
    #expect(updatedSession.score[note] ?? (0, 0) == (3, 2))
  }

  @Test
  func logCorrectAndWrongAnswersForDifferentNotesForDifferentQuestions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note1 = Note(name: .c, octave: 1)
    let note2 = Note(name: .fSharp, octave: 2)
    let _ = try await manager.startSession()
    let question1 = Question(answer: note1, resolution: [])
    let question2 = Question(answer: note2, resolution: [])
    let question3 = Question(answer: note1, resolution: [])
    let question4 = Question(answer: note2, resolution: [])
    let question5 = Question(answer: note2, resolution: [])

    let _ = try await manager.logCorrectAnswer(note2, for: question1)
    let _ = try await manager.logWrongAnswer(note2, for: question2)
    let _ = try await manager.logWrongAnswer(note1, for: question3)
    let _ = try await manager.logCorrectAnswer(note1, for: question4)
    let updatedSession = try await manager.logCorrectAnswer(note2, for: question5)

    #expect(updatedSession.score.count == 2)
    #expect(updatedSession.score[note1] ?? (0, 0) == (1, 1))
    #expect(updatedSession.score[note2] ?? (0, 0) == (2, 1))
  }

  @Test
  func stopCurrentSessionReturnsLevelWithUpdatedSessions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .aFlat, octave: 2)

    try await manager.prepareToPractice()
    let _ = try await manager.moveToNextLevel()
    let _ = try await manager.startSession()
    let question = Question(answer: note, resolution: [])

    let _ = try await manager.logCorrectAnswer(note, for: question)

    let level = try await manager.stopCurrentSession()

    #expect(level.sessions.count == 1)

    let session = try #require(level.sessions.first)

    #expect(session.score.count == 1)
    #expect(session.score[note] ?? (0, 0) == (1, 0))
  }

  @Test
  func multiplestopCurrentSessionInARowReturnLevelWithUpdatedSessions() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .aFlat, octave: 2)

    try await manager.prepareToPractice()
    let _ = try await manager.moveToNextLevel()

    // Session #1

    let _ = try await manager.startSession()
    let question = Question(answer: note, resolution: [])

    let _ = try await manager.logCorrectAnswer(note, for: question)

    let level = try await manager.stopCurrentSession()

    #expect(level.sessions.count == 1)

    let session = try #require(level.sessions.first)

    #expect(session.score.count == 1)
    #expect(session.score[note] ?? (0, 0) == (1, 0))

    // Session #2

    let _ = try await manager.startSession()
    let question2 = Question(answer: note, resolution: [])

    let _ = try await manager.logWrongAnswer(note, for: question2)

    let level2 = try await manager.stopCurrentSession()

    let session2 = try #require(level2.sessions.last)

    #expect(session2.score.count == 1)
    #expect(session2.score[note] ?? (0, 0) == (0, 1))
  }

  @Test
  func stopCurrentSessionPersistsSessionToStorage() async throws {
    let storage = MockSessionStorage()
    let manager = CyclicPracticeManager(
      storage: storage,
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .aFlat, octave: 2)

    try await manager.prepareToPractice()
    let _ = try await manager.moveToNextLevel()
    let _ = try await manager.startSession()
    let question = Question(answer: note, resolution: [])

    let _ = try await manager.logCorrectAnswer(note, for: question)

    let _ = try await manager.stopCurrentSession()

    await #expect(storage.isSaveSessionCalled == true)

    let savedSession = try #require(await storage.getSavedSession())

    #expect(savedSession.score.count == 1)
    #expect(savedSession.score[note] ?? (0, 0) == (1, 0))
  }

  @Test
  func stopCurrentSessionDoesNotPersistSessionForCustomLevel() async throws {
    let storage = MockSessionStorage()
    let manager = CyclicPracticeManager(
      storage: storage,
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let note = Note(name: .aFlat, octave: 2)

    try await manager.prepareToPractice()
    let _ = try await manager.moveToNextLevel()
    let _ = try await manager.startSession()
    let _ = try await manager.setCurrentLevel(makeLevel(id: 1).withNotes([]))

    let question = Question(answer: note, resolution: [])

    let _ = try await manager.logCorrectAnswer(note, for: question)

    let _ = try await manager.stopCurrentSession()

    await #expect(storage.isSaveSessionCalled == false)
    await #expect(storage.savedSession == nil)
  }

  @Test
  func stopCurrentSessionDoesNotPersistSessionsWithEmptyScores() async throws {
    let storage = MockSessionStorage()
    let manager = CyclicPracticeManager(
      storage: storage,
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )

    try await manager.prepareToPractice()
    let _ = try await manager.moveToNextLevel()
    let _ = try await manager.startSession()

    let _ = try await manager.stopCurrentSession()

    await #expect(storage.isSaveSessionCalled == false)
    await #expect(storage.savedSession == nil)
  }

  @Test
  func moveToNextQuestionSelectNoteInLevel() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    try await manager.prepareToPractice()
    let _ = try await manager.moveToNextLevel()
    let _ = try await manager.startSession()
    let level = try await manager.setCurrentLevel(
      makeLevel(id: 1).withNotes([
        Note(name: .d, octave: 1),
        Note(name: .bFlat, octave: 2),
        Note(name: .g, octave: 1),
        Note(name: .e, octave: 2),
      ])
    )

    let question = try await manager.moveToNextQuestion()

    #expect(level.notes.contains(question.answer))
  }

  @Test func moveToNextLevelRestoresTheLastPlayedLevel() async throws {
    let preferences = MockPreferences()
    preferences.setValue(1, for: "practice.level.cursor")


    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: preferences
    )

    try await manager.prepareToPractice()
    let level = try await manager.moveToNextLevel()

    #expect(level.id == 3)
    #expect(level.key == .c)
    #expect(level.isMajor == true)
    #expect(level.title == "C major")
    #expect(level.range == .entireOctave)
  }

  @Test
  func moveToNextLevelCyclesThroughAllKeysInFourths() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let keys: [NoteName] = [.c, .f, .bFlat, .eFlat, .aFlat, .dFlat, .gFlat, .b, .e, .a, .d, .g]
    try await manager.prepareToPractice()

    for key in keys {
      for isMajor in [true, false] {
        var level = try await manager.moveToNextLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == false)
        #expect(level.range == .firstHalfOfOctave)

        level = try await manager.moveToNextLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == false)
        #expect(level.range == .secondHalfOfOctave)

        level = try await manager.moveToNextLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == false)
        #expect(level.range == .entireOctave)

        level = try await manager.moveToNextLevel()

//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == false)
//        #expect(level.range == .firstHalfOfOctave)
//
//        level = try await manager.moveToNextLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == false)
//        #expect(level.range == .secondHalfOfOctave)
//
//        level = try await manager.moveToNextLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == false)
//        #expect(level.range == .entireOctave)
//
//        level = try await manager.moveToNextLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == true)
        #expect(level.range == .firstHalfOfOctave)

        level = try await manager.moveToNextLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == true)
        #expect(level.range == .secondHalfOfOctave)

        level = try await manager.moveToNextLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == true)
        #expect(level.range == .entireOctave)

//        level = try await manager.moveToNextLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == true)
//        #expect(level.range == .firstHalfOfOctave)
//
//        level = try await manager.moveToNextLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == true)
//        #expect(level.range == .secondHalfOfOctave)
//
//        level = try await manager.moveToNextLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == true)
//        #expect(level.range == .entireOctave)
      }
    }

    let level = try await manager.moveToNextLevel()

    #expect(level.key == .c)
    #expect(level.isMajor == true)
    #expect(level.spansMultipleOctaves == false)
    #expect(level.isChromatic == false)
    #expect(level.range == .firstHalfOfOctave)
  }

  @Test
  func moveToPreviousLevelCyclesThroughAllKeysInFifths() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )
    let keys: [NoteName] = [.g, .d, .a, .e, .b, .gFlat, .dFlat, .aFlat, .eFlat, .bFlat, .f, .c]
    try await manager.prepareToPractice()

    for key in keys {
      for isMajor in [false, true] {
        var level = try await manager.moveToPreviousLevel()

//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == true)
//        #expect(level.range == .entireOctave)
//
//        level = try await manager.moveToPreviousLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == true)
//        #expect(level.range == .secondHalfOfOctave)
//
//        level = try await manager.moveToPreviousLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == true)
//        #expect(level.range == .firstHalfOfOctave)
//
//        level = try await manager.moveToPreviousLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == true)
        #expect(level.range == .entireOctave)

        level = try await manager.moveToPreviousLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == true)
        #expect(level.range == .secondHalfOfOctave)

        level = try await manager.moveToPreviousLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == true)
        #expect(level.range == .firstHalfOfOctave)

        level = try await manager.moveToPreviousLevel()

//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == false)
//        #expect(level.range == .entireOctave)
//
//        level = try await manager.moveToPreviousLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == false)
//        #expect(level.range == .secondHalfOfOctave)
//
//        level = try await manager.moveToPreviousLevel()
//
//        #expect(level.key == key)
//        #expect(level.isMajor == isMajor)
//        #expect(level.spansMultipleOctaves == true)
//        #expect(level.isChromatic == false)
//        #expect(level.range == .firstHalfOfOctave)
//
//        level = try await manager.moveToPreviousLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == false)
        #expect(level.range == .entireOctave)

        level = try await manager.moveToPreviousLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == false)
        #expect(level.range == .secondHalfOfOctave)

        level = try await manager.moveToPreviousLevel()

        #expect(level.key == key)
        #expect(level.isMajor == isMajor)
        #expect(level.spansMultipleOctaves == false)
        #expect(level.isChromatic == false)
        #expect(level.range == .firstHalfOfOctave)
      }
    }

    let level = try await manager.moveToPreviousLevel()

    #expect(level.key == .g)
    #expect(level.isMajor == false)
    #expect(level.spansMultipleOctaves == false)
    #expect(level.isChromatic == true)
    #expect(level.range == .entireOctave)
  }

  @Test
  func useTemporaryLevel() async throws {
    let manager = CyclicPracticeManager(
      storage: MockSessionStorage(),
      levelGenerator: MockLevelGenerator(),
      noteResolutionGenerator: MockNoteResolutionGenerator(),
      preferences: MockPreferences()
    )

    let level = try await manager.setCurrentLevel(
      makeLevel(id: 1).withNotes([
        Note(name: .c, octave: 4),
      ])
    )
    #expect(level.id == 1)
    #expect(level.notes.count == 1)
    #expect(level.notes[0] == Note(name: .c, octave: 4))
  }

  // MARK: - Private Helpers

  func makeLevel(id: Int) -> Level {
    Level(
      id: id,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .firstHalfOfOctave,
      sessions: []
    )
  }
}

// MARK: - Mocks

private struct MockLevelGenerator: LevelGenerator {
  func makeLevel(
    withId id: Int,
    inMajorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includeChromaticNotes: Bool,
    limitingNotesTo range: NoteRange
  ) -> Level {
    Level(
      id: id,
      key: key,
      isMajor: true,
      isChromatic: includeChromaticNotes,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: spansMultipleOctaves,
      range: range,
      sessions: []
    )
  }
  
  func makeLevel(
    withId id: Int,
    inMinorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includeChromaticNotes: Bool,
    limitingNotesTo range: Bemol.NoteRange
  ) -> Level {
    Level(
      id: id,
      key: key,
      isMajor: false,
      isChromatic: includeChromaticNotes,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: spansMultipleOctaves,
      range: range,
      sessions: []
    )
  }
}

private final class MockNoteResolutionGenerator: NoteResolutionGenerator {
  var isResolutionInMajorKeyCalled = false
  var isResolutionInMinorKeyCalled = false

  func resolution(
    for note: Note,
    inMajorKey key: NoteName,
    includingChromaticNotes includeChromaticNotes: Bool
  ) -> Resolution {
    isResolutionInMajorKeyCalled = true
    return []
  }
  
  func resolution(
    for note: Note,
    inMinorKey key: NoteName,
    includingChromaticNotes includeChromaticNotes: Bool
  ) -> Resolution {
    isResolutionInMinorKeyCalled = true
    return []
  }
}

private actor MockSessionStorage: SessionStorage {
  var isSaveSessionCalled = false
  var savedSession: Session? = nil

  func saveSession(_ session: Session, level: Level) async throws {
    isSaveSessionCalled = true
    savedSession = session
  }
  
  func loadSessions(for level: Bemol.Level) async throws -> [Bemol.Session] {
    []
  }

  func getSavedSession() async -> Session? {
    savedSession
  }
}

// MARK: - Mocks

private final class MockPreferences: Preferences {
  private var value: Int? = nil

  func value(for key: String) -> Int? {
    value
  }

  func setValue(_ value: Int, for key: String) {
    self.value = value
  }

  func value(for key: String) -> Bool {
    false
  }

  func setValue(_ value: Bool, for key: String) {
  }
}
