///
/// AppEffect.swift
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

enum AppEffect: Equatable {
  case prepareToPractice
  case loadLevel(Level)
  case loadFirstLevel
  case loadRandomLevel
  case loadPreviousLevel
  case loadNextLevel
  case startSession
  case stopSession
  case playNote(Note)
  case playNoteInResolution(Note?)
  case repeatQuestion(Level, Question)
  case playCadence(Level, Question)
  case loadNextQuestion
  case logRightAnswer(Note, Question)
  case logWrongAnswer(Note, Question)
}
