///
/// Level.swift
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

enum NoteRange {
  case firstHalfOfOctave
  case secondHalfOfOctave
  case entireOctave
}

struct Level {
  let id: Int
  let key: NoteName
  let isMajor: Bool
  var isMinor: Bool { !isMajor }
  let isChromatic: Bool
  let notes: [Note]
  let cadence: Cadence
  let spansMultipleOctaves: Bool
  let range: NoteRange
  let isCustom: Bool
  let sessions: [Session]

  init(
    id: Int,
    key: NoteName,
    isMajor: Bool,
    isChromatic: Bool,
    notes: [Note],
    cadence: Cadence,
    spansMultipleOctaves: Bool,
    range: NoteRange,
    isCustom: Bool = false,
    sessions: [Session]
  ) {
    self.id = id
    self.key = key
    self.isMajor = isMajor
    self.isChromatic = isChromatic
    self.notes = notes
    self.cadence = cadence
    self.spansMultipleOctaves = spansMultipleOctaves
    self.range = range
    self.isCustom = isCustom
    self.sessions = sessions
  }
}

extension Level {
  var title: String {
    let major = String(localized: "major")
    let minor = String(localized: "minor")
    let value = "\(key.letter) \(isMajor ? major : minor)\(isCustom ? " *" : "")"

    if spansMultipleOctaves {
      return value + " · 8.."
    } else {
      return value
    }
  }
}

extension Level {
  var summary: (average: Double, averagePerNote: [Note: Double]) {
    var correctPerNote: [Note: Int] = [:]
    var wrongPerNote: [Note: Int] = [:]
    var sumPerNote: [Note: Int] = [:]
    var averagePerNote: [Note: Double] = [:]
    var sumOfAveragesForAllNotes = 0.0
    var levelAverage = 0.0

    for session in sessions {
      for (note, values) in session.score {
        correctPerNote[note] = (correctPerNote[note] ?? 0) + values.correct
        wrongPerNote[note] = (wrongPerNote[note] ?? 0) + values.wrong
        sumPerNote[note] = correctPerNote[note]! + wrongPerNote[note]!
      }
    }

    for (note, value) in correctPerNote {
      if let sum = sumPerNote[note], sum > 0 {
        averagePerNote[note] = Double(value) / Double(sum)
      }
    }

    for note in notes {
      sumOfAveragesForAllNotes += averagePerNote[note] ?? 0.0
    }

    if notes.count > 0 {
      levelAverage = sumOfAveragesForAllNotes / Double(notes.count)
    }

    return (levelAverage, averagePerNote)
  }
}

extension Level {
  func withNotes(_ notes: [Note]) -> Level {
    Level(
      id: id,
      key: key,
      isMajor: isMajor,
      isChromatic: isChromatic,
      notes: notes,
      cadence: cadence,
      spansMultipleOctaves: spansMultipleOctaves,
      range: range,
      isCustom: true,
      sessions: []
    )
  }

  func withSessions(_ sessions: [Session]) -> Level {
    Level(
      id: id,
      key: key,
      isMajor: isMajor,
      isChromatic: isChromatic,
      notes: notes,
      cadence: cadence,
      spansMultipleOctaves: spansMultipleOctaves,
      range: range,
      isCustom: isCustom,
      sessions: sessions
    )
  }
}
