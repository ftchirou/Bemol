///
/// Session.swift
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

struct Score: Equatable {
  let correct: Int
  let wrong: Int

  static var zero: Score {
    Score(correct: 0, wrong: 0)
  }
}

struct Session: Equatable {
  let timestamp: TimeInterval
  let score: [Note: Score]
}

extension Session {
  var summary: (correct: Int, wrong: Int, average: Double, averagePerNote: [Note: Double]) {
    var correct = 0
    var wrong = 0
    var average = 0.0
    var averagePerNote: [Note: Double] = [:]

    for (note, values) in score {
      correct += values.correct
      wrong += values.wrong

      if values.correct + values.wrong > 0 {
        averagePerNote[note] = Double(values.correct) / Double(values.correct + values.wrong)
      }
    }

    if correct + wrong > 0 {
      average = Double(correct) / Double(correct + wrong)
    }

    return (correct, wrong, average, averagePerNote)
  }
}
