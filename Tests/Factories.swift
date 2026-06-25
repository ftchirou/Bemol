///
/// Factories.swift
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

@testable import Bemol

@MainActor
func makeAppEnvironment(
  notePlayer: (any NotePlayer)? = nil,
  practiceManager: (any PracticeManager)? = nil,
  tipProvider: (any TipProvider)? = nil,
  preferences: (any Preferences)? = nil,
  logger: Logger = Logger()
) -> AppEnvironment {
  AppEnvironment(
    notePlayer: notePlayer ?? MockNotePlayer(),
    practiceManager: practiceManager ?? MockPracticeManager(),
    tipProvider: tipProvider ?? MockTipProvider(),
    preferences: preferences ?? MockPreferences(),
    logger: logger
  )
}

@MainActor
func makeLevel(
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

@MainActor
func makeSession() -> Session {
  Session(timestamp: Date.now.timeIntervalSince1970, score: [:])
}

@MainActor
func makeQuestion(
  answer: Note? = nil,
  resolution: Resolution = []
) -> Question {
  Question(
    answer: answer ?? Note(name: .dFlat, octave: 1),
    resolution: resolution
  )
}
