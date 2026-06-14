///
/// LevelGenerator.swift
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

protocol LevelGenerator {
  func makeLevel(
    withId id: Int,
    inMajorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includeChromaticNotes: Bool,
    limitingNotesTo range: NoteRange
  ) -> Level

  func makeLevel(
    withId id: Int,
    inMinorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includeChromaticNotes: Bool,
    limitingNotesTo range: NoteRange
  ) -> Level
}

// MARK: -

struct DiatonicLevelGenerator: LevelGenerator {
  func makeLevel(
    withId id: Int,
    inMajorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includesChromaticNotes: Bool,
    limitingNotesTo range: NoteRange
  ) -> Level {
    switch (range, includesChromaticNotes) {
    case (.firstHalfOfOctave, false):
      makeLevel(
        usingPattern: [0, 2, 4, 5],
        withId: id,
        inMajorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.firstHalfOfOctave, true):
      makeLevel(
        usingPattern: [0, 1, 2, 3, 4, 5],
        withId: id,
        inMajorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.secondHalfOfOctave, false):
      makeLevel(
        usingPattern: [7, 9, 11, 12],
        withId: id,
        inMajorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.secondHalfOfOctave, true):
      makeLevel(
        usingPattern: [6, 7, 8, 9, 10, 11, 12],
        withId: id,
        inMajorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.entireOctave, false):
      makeLevel(
        usingPattern: [0, 2, 4, 5, 7, 9, 11, 12],
        withId: id,
        inMajorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.entireOctave, true):
      makeLevel(
        usingPattern: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        withId: id,
        inMajorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )
    }
  }

  func makeLevel(
    withId id: Int,
    inMinorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includesChromaticNotes: Bool,
    limitingNotesTo range: NoteRange
  ) -> Level {
    switch (range, includesChromaticNotes) {
    case (.firstHalfOfOctave, false):
      makeLevel(
        usingPattern: [0, 2, 3, 5],
        withId: id,
        inMinorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.firstHalfOfOctave, true):
      makeLevel(
        usingPattern: [0, 1, 2, 3, 4, 5],
        withId: id,
        inMinorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.secondHalfOfOctave, false):
      makeLevel(
        usingPattern: [7, 8, 11, 12],
        withId: id,
        inMinorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.secondHalfOfOctave, true):
      makeLevel(
        usingPattern: [6, 7, 8, 9, 10, 11, 12],
        withId: id,
        inMinorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.entireOctave, false):
      makeLevel(
        usingPattern: [0, 2, 3, 5, 7, 8, 11, 12],
        withId: id,
        inMinorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )

    case (.entireOctave, true):
      makeLevel(
        usingPattern: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        withId: id,
        inMinorKey: key,
        spanningMultipleOctaves: spansMultipleOctaves,
        includingChromaticNotes: includesChromaticNotes,
        limitingNotesTo: range
      )
    }
  }

  private func makeLevel(
    usingPattern pattern: [UInt8],
    withId id: Int,
    inMajorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includesChromaticNotes: Bool,
    limitingNotesTo range: NoteRange
  ) -> Level {
    return Level(
      id: id,
      key: key,
      isMajor: true,
      isChromatic: includesChromaticNotes,
      notes: pattern.map {
        let nextNote = key.halfSteps($0)
        let octave = position(of: nextNote, positionInScale: $0, relativeTo: key)
        return Note(name: nextNote, octave: octave)
      },
      cadence: makeMajorCadence(tonic: key),
      spansMultipleOctaves: spansMultipleOctaves,
      range: range,
      sessions: []
    )
  }

  private func makeLevel(
    usingPattern pattern: [UInt8],
    withId id: Int,
    inMinorKey key: NoteName,
    spanningMultipleOctaves spansMultipleOctaves: Bool,
    includingChromaticNotes includesChromaticNotes: Bool,
    limitingNotesTo range: NoteRange
  ) -> Level {
    Level(
      id: id,
      key: key,
      isMajor: false,
      isChromatic: includesChromaticNotes,
      notes: pattern.map {
        let nextNote = key.halfSteps($0)
        let octave = position(of: nextNote, positionInScale: $0, relativeTo: key)
        return Note(name: nextNote, octave: octave)
      },
      cadence: makeMinorCadence(tonic: key),
      spansMultipleOctaves: spansMultipleOctaves,
      range: range,
      sessions: []
    )
  }

  private func position(
    of note: NoteName,
    positionInScale: UInt8,
    relativeTo base: NoteName
  ) -> UInt8 {
    if note.rawValue == base.rawValue && positionInScale > 0 {
      return 2
    }

    if note.index(inKey: .c) < base.index(inKey: .c) {
      return 2
    }

    return 1
  }

  private func makeMajorCadence(tonic: NoteName) -> Cadence {
    return Cadence(
      voices: [tonic, tonic.majorThird, tonic.fifth],
      roots: [tonic, tonic.fourth, tonic.fifth, tonic],
      movement: [
        [0, 0, 0],
        [0, 1, 2],
        [-1, -2, 0],
        [0, 0, 0],
      ]
    )
  }

  private func makeMinorCadence(tonic: NoteName) -> Cadence {
    return Cadence(
      voices: [tonic, tonic.minorThird, tonic.fifth],
      roots: [tonic, tonic.fourth, tonic.fifth, tonic],
      movement: [
        [0, 0, 0],
        [0, 2, 1],
        [-1, -1, 0],
        [0, 0, 0],
      ]
    )
  }
}
