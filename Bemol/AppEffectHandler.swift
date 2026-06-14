///
/// AppLoop.swift
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
///

import Foundation
import os

@MainActor
final class AppEffectHandler {
  private let environment: AppEnvironment

  init(environment: AppEnvironment) {
    self.environment = environment
  }

  func handleEffect(_ effect: AppEffect) async -> AppAction? {
    do {
      switch effect {
      case .prepareToPractice:
        try await environment.notePlayer.prepareToPlay()
        try await environment.practiceManager.prepareToPractice()
        let level = try await environment.practiceManager.moveToNextLevel()

        return .didLoadLevel(level)

      case .loadLevel(let level):
        let level = try await environment.practiceManager.setCurrentLevel(level)
        return .didLoadLevel(level)

      case .loadFirstLevel:
        let level = try await environment.practiceManager.moveToFirstLevel()
        return .didLoadLevel(level)

      case .loadRandomLevel:
        let level = try await environment.practiceManager.moveToRandomLevel()
        return .didLoadLevel(level)

      case .loadPreviousLevel:
        let level = try await environment.practiceManager.moveToPreviousLevel()
        return .didLoadLevel(level)

      case .loadNextLevel:
        let level = try await environment.practiceManager.moveToNextLevel()
        return .didLoadLevel(level)

      case .startSession:
        let session = try await environment.practiceManager.startSession()
        return .didStartSession(session)

      case .stopSession:
        let level = try await environment.practiceManager.stopCurrentSession()
        return .didLoadLevel(level)

      case .repeatQuestion(let level, let question):
        try await environment.notePlayer.playCadence(level.cadence)
        try await environment.notePlayer.playNote(question.answer)

        return .didPlayCadence

      case .playNote(let note):
        try await environment.notePlayer.playNote(note)
        return nil

      case .playNoteInResolution(let note):
        if let note {
          try await environment.notePlayer.playNote(note)
        }

        return .didPlayNoteInResolution

      case .loadNextQuestion:
        let question = try await environment.practiceManager.moveToNextQuestion()
        return .didLoadQuestion(question)

      case .logRightAnswer(let answer, let question):
        let session = try await environment.practiceManager.logCorrectAnswer(answer, for: question)
        return .didLogRightAnswer(session)

      case .logWrongAnswer(let answer, let question):
        try await environment.notePlayer.playNote(answer)
        let session = try await environment.practiceManager.logWrongAnswer(answer, for: question)

        return .didLogWrongAnswer(session)

      case .playCadence(let level, let question):
        try await environment.notePlayer.playCadence(level.cadence)
        try await environment.notePlayer.playNote(question.answer)

        return .didPlayCadence
      }
    } catch {
      environment.logger.log(level: .error, "\(error)")
      return .errorOccurred(error)
    }
  }
}
