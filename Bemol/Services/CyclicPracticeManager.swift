///
/// CyclicPracticeManager.swift
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

actor CyclicPracticeManager: PracticeManager {
  enum Error: Swift.Error {
    case noSessionInProgress
    case unexpected
  }

  private let preferenceKey = "practice.level.cursor"
  private let storage: SessionStorage
  private let levelGenerator: LevelGenerator
  private let noteResolutionGenerator: NoteResolutionGenerator
  private let preferences: Preferences

  private var allLevels: [Level] = []
  private var cursor = -1
  private var currentLevel: Level? = nil
  private var currentSession: Session? = nil
  private var currentQuestion: Question? = nil
  private var currentQuestionIndex = (0...4).randomElement()!
  private var currentNotes: [Note] = []
  private var lastAnsweredQuestion: Question? = nil

  init(
    storage: SessionStorage,
    levelGenerator: LevelGenerator,
    noteResolutionGenerator: NoteResolutionGenerator,
    preferences: Preferences
  ) {
    self.storage = storage
    self.levelGenerator = levelGenerator
    self.noteResolutionGenerator = noteResolutionGenerator
    self.preferences = preferences
    self.cursor = preferences.value(for: preferenceKey) ?? -1
  }

  func prepareToPractice() async throws {
    self.allLevels = await makeLevelsInFourths()
  }

  func moveToPreviousLevel() async throws -> Level {
    decrementCursor()
    return try await moveToLevelAtCursor()
  }
  
  func moveToNextLevel() async throws -> Level {
    incrementCursor()
    return try await moveToLevelAtCursor()
  }

  func moveToRandomLevel() async throws -> Level {
    cursor = (0..<allLevels.count).randomElement() ?? 0
    return try await moveToLevelAtCursor()
  }

  func moveToFirstLevel() async throws -> Level {
    cursor = 0
    return try await moveToLevelAtCursor()
  }

  func startSession() async throws -> Session {
    currentSession = Session(timestamp: Date.now.timeIntervalSince1970, score: [:])
    return currentSession!
  }
  
  func stopCurrentSession() async throws -> Level {
    guard let level = currentLevel else { throw Error.unexpected }
    guard let session = currentSession else { throw Error.noSessionInProgress }
    guard !level.isCustom else { return level.withSessions([session]) }
    guard !session.score.isEmpty else { return level }

    try await storage.saveSession(session, level: level)

    currentLevel = level.withSessions(level.sessions + [session])
    return currentLevel!
  }

  func useTemporaryLevel(level: Level) async throws -> Level {
    currentLevel = level
    currentNotes = level.notes.shuffled()
    return level
  }

  func moveToNextQuestion() async throws -> Question {
    guard let level = currentLevel else { throw Error.unexpected }

    if currentQuestionIndex + 1 >= currentNotes.count {
      currentNotes = currentNotes.shuffled()
      currentQuestionIndex = 0
    } else {
      currentQuestionIndex += 1
    }

    let note = currentNotes[currentQuestionIndex]

    let resolution = if level.isMajor {
      noteResolutionGenerator.resolution(
        for: note,
        inMajorKey: level.key,
        includingChromaticNotes: level.isChromatic
      )
    } else {
      noteResolutionGenerator.resolution(
        for: note,
        inMinorKey: level.key,
        includingChromaticNotes: level.isChromatic
      )
    }

    let question = Question(answer: note, resolution: resolution)
    self.currentQuestion = question

    return question
  }
  
  func logCorrectAnswer(_ note: Note, for question: Question) async throws -> Session {
    guard var session = currentSession else {
      throw Error.noSessionInProgress
    }

    if let lastAnsweredQuestion, lastAnsweredQuestion.id == question.id {
      return session
    }

    self.lastAnsweredQuestion = question

    var score = session.score

    if let noteScore = score[question.answer] {
      score[question.answer] = (noteScore.0 + 1, noteScore.1)
      session = Session(timestamp: session.timestamp, score: score)

      self.currentSession = session

      return session
    }

    score[question.answer] = (1, 0)
    session = Session(timestamp: session.timestamp, score: score)

    self.currentSession = session

    return session
  }
  
  func logWrongAnswer(_ note: Note, for question: Question) async throws -> Session {
    guard var session = currentSession else {
      throw Error.noSessionInProgress
    }

    if let lastAnsweredQuestion, lastAnsweredQuestion.id == question.id {
      return session
    }

    self.lastAnsweredQuestion = question

    var score = session.score

    if let noteScore = score[question.answer] {
      score[question.answer] = (noteScore.0, noteScore.1 + 1)
      session = Session(timestamp: session.timestamp, score: score)

      self.currentSession = session

      return session
    }

    score[question.answer] = (0, 1)
    session = Session(timestamp: session.timestamp, score: score)

    self.currentSession = session

    return session
  }

  // MARK: - Private

  private func moveToLevelAtCursor() async throws -> Level {
    let level = allLevels[cursor]
    let sessions = try await storage.loadSessions(for: level)

    allLevels[cursor] = allLevels[cursor].withSessions(sessions)
    currentLevel = allLevels[cursor]

    preferences.setValue(cursor - 1, for: preferenceKey)
    currentNotes = level.notes.shuffled()

    return allLevels[cursor]
  }

  private func decrementCursor() {
    if cursor <= 0 {
      cursor = allLevels.count - 1
      return
    }

    cursor -= 1
  }

  private func incrementCursor() {
    if cursor >= allLevels.count - 1 {
      cursor = 0
      return
    }

    cursor += 1
  }

  private func makeLevelsInFourths() async -> [Level] {
    var levels: [Level] = []
    var levelId = 1
    let keys: [NoteName] = [.c, .f, .bFlat, .eFlat, .aFlat, .dFlat, .gFlat, .b, .e, .a, .d, .g]

    for key in keys {
      for includesChromatics in [false, true] {
        for spansMultipleOctaves in [false, /* true */] {
          for range in [NoteRange.firstHalfOfOctave, .secondHalfOfOctave, .entireOctave] {
            levels.append(
              levelGenerator.makeLevel(
                withId: levelId,
                inMajorKey: key,
                spanningMultipleOctaves: spansMultipleOctaves,
                includingChromaticNotes: includesChromatics,
                limitingNotesTo: range
              )
            )

            levelId += 1
          }
        }
      }

      for includesChromatics in [false, true] {
        for spansMultipleOctaves in [false, /* true */] {
          for range in [NoteRange.firstHalfOfOctave, .secondHalfOfOctave, .entireOctave] {
            levels.append(
              levelGenerator.makeLevel(
                withId: levelId,
                inMinorKey: key,
                spanningMultipleOctaves: spansMultipleOctaves,
                includingChromaticNotes: includesChromatics,
                limitingNotesTo: range
              )
            )

            levelId += 1
          }
        }
      }
    }

    return levels
  }
}
