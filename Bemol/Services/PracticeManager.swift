///
/// PracticeManager.swift
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

protocol PracticeManager: Actor {
  func prepareToPractice() async throws
  func moveToPreviousLevel() async throws -> Level
  func moveToNextLevel() async throws -> Level
  func moveToRandomLevel() async throws -> Level
  func moveToFirstLevel() async throws -> Level
  func startSession() async throws -> Session
  func stopCurrentSession() async throws -> Level
  func moveToNextQuestion() async throws -> Question
  func logCorrectAnswer(_ note: Note, for question: Question) async throws -> Session
  func logWrongAnswer(_ note: Note, for question: Question) async throws -> Session
  func setCurrentLevel(_ level: Level) async throws -> Level
}
