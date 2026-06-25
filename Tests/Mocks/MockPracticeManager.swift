///
/// MockPracticeManager.swift
/// Bemol
///
/// Copyright 2026 Faiçal Tchirou
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

import Foundation

@testable import Bemol

final class MockPracticeManager: PracticeManager {
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

  func setCurrentLevel(_ level: Level) async throws -> Level {
    isUseTemporaryLevelCalled = true
    temporaryLevel = level
    return level
  }

  func getTemporaryLevel() async -> Level? {
    temporaryLevel
  }
}
