///
/// DiatonicLevelGeneratorTests.swift
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

@MainActor
struct DiatonicLevelGeneratorTests {
  // MARK: - Major

  @Test
  func makeFirstHalfMajorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let dFlatMajorLevel = generator.makeLevel(
      withId: 42,
      inMajorKey: .dFlat,
      spanningMultipleOctaves: false,
      includingChromaticNotes: false,
      limitingNotesTo: .firstHalfOfOctave
    )

    #expect(dFlatMajorLevel.id == 42)
    #expect(dFlatMajorLevel.key == .dFlat)
    #expect(dFlatMajorLevel.isMajor == true)
    #expect(dFlatMajorLevel.spansMultipleOctaves == false)
    #expect(dFlatMajorLevel.range == .firstHalfOfOctave)
    #expect(dFlatMajorLevel.sessions.isEmpty == true)
    #expect(
      dFlatMajorLevel.notes == [
        Note(name: .dFlat, octave: 1),
        Note(name: .eFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .gFlat, octave: 1),
      ])
    #expect(
      dFlatMajorLevel.cadence
        == Cadence(
          voices: [.dFlat, .f, .aFlat],
          roots: [.dFlat, .gFlat, .aFlat, .dFlat],
          movement: [
            [0, 0, 0],
            [0, 1, 2],
            [-1, -2, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeSecondHalfMajorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let dFlatMajorLevel = generator.makeLevel(
      withId: 42,
      inMajorKey: .dFlat,
      spanningMultipleOctaves: false,
      includingChromaticNotes: false,
      limitingNotesTo: .secondHalfOfOctave
    )

    #expect(dFlatMajorLevel.id == 42)
    #expect(dFlatMajorLevel.key == .dFlat)
    #expect(dFlatMajorLevel.isMajor == true)
    #expect(dFlatMajorLevel.spansMultipleOctaves == false)
    #expect(dFlatMajorLevel.range == .secondHalfOfOctave)
    #expect(dFlatMajorLevel.sessions.isEmpty == true)
    #expect(
      dFlatMajorLevel.notes == [
        Note(name: .aFlat, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
      ])
    #expect(
      dFlatMajorLevel.cadence
        == Cadence(
          voices: [.dFlat, .f, .aFlat],
          roots: [.dFlat, .gFlat, .aFlat, .dFlat],
          movement: [
            [0, 0, 0],
            [0, 1, 2],
            [-1, -2, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeEntireOctaveMajorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let dFlatMajorLevel = generator.makeLevel(
      withId: 42,
      inMajorKey: .dFlat,
      spanningMultipleOctaves: false,
      includingChromaticNotes: false,
      limitingNotesTo: .entireOctave
    )

    #expect(dFlatMajorLevel.id == 42)
    #expect(dFlatMajorLevel.key == .dFlat)
    #expect(dFlatMajorLevel.isMajor == true)
    #expect(dFlatMajorLevel.spansMultipleOctaves == false)
    #expect(dFlatMajorLevel.range == .entireOctave)
    #expect(dFlatMajorLevel.sessions.isEmpty == true)
    #expect(
      dFlatMajorLevel.notes == [
        Note(name: .dFlat, octave: 1),
        Note(name: .eFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .gFlat, octave: 1),
        Note(name: .aFlat, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
      ])
    #expect(
      dFlatMajorLevel.cadence
        == Cadence(
          voices: [.dFlat, .f, .aFlat],
          roots: [.dFlat, .gFlat, .aFlat, .dFlat],
          movement: [
            [0, 0, 0],
            [0, 1, 2],
            [-1, -2, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeFirstHalfChromaticMajorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let dFlatMajorLevel = generator.makeLevel(
      withId: 42,
      inMajorKey: .dFlat,
      spanningMultipleOctaves: false,
      includingChromaticNotes: true,
      limitingNotesTo: .firstHalfOfOctave
    )

    #expect(dFlatMajorLevel.id == 42)
    #expect(dFlatMajorLevel.key == .dFlat)
    #expect(dFlatMajorLevel.isMajor == true)
    #expect(dFlatMajorLevel.spansMultipleOctaves == false)
    #expect(dFlatMajorLevel.range == .firstHalfOfOctave)
    #expect(dFlatMajorLevel.sessions.isEmpty == true)
    #expect(
      dFlatMajorLevel.notes == [
        Note(name: .dFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .eFlat, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .gFlat, octave: 1),
      ])
    #expect(
      dFlatMajorLevel.cadence
        == Cadence(
          voices: [.dFlat, .f, .aFlat],
          roots: [.dFlat, .gFlat, .aFlat, .dFlat],
          movement: [
            [0, 0, 0],
            [0, 1, 2],
            [-1, -2, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeSecondHalfChromaticMajorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let dFlatMajorLevel = generator.makeLevel(
      withId: 42,
      inMajorKey: .dFlat,
      spanningMultipleOctaves: false,
      includingChromaticNotes: true,
      limitingNotesTo: .secondHalfOfOctave
    )

    #expect(dFlatMajorLevel.id == 42)
    #expect(dFlatMajorLevel.key == .dFlat)
    #expect(dFlatMajorLevel.isMajor == true)
    #expect(dFlatMajorLevel.spansMultipleOctaves == false)
    #expect(dFlatMajorLevel.range == .secondHalfOfOctave)
    #expect(dFlatMajorLevel.sessions.isEmpty == true)
    #expect(
      dFlatMajorLevel.notes == [
        Note(name: .g, octave: 1),
        Note(name: .aFlat, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
      ])
    #expect(
      dFlatMajorLevel.cadence
        == Cadence(
          voices: [.dFlat, .f, .aFlat],
          roots: [.dFlat, .gFlat, .aFlat, .dFlat],
          movement: [
            [0, 0, 0],
            [0, 1, 2],
            [-1, -2, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeEntireOctaveChromaticMajorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let dFlatMajorLevel = generator.makeLevel(
      withId: 42,
      inMajorKey: .dFlat,
      spanningMultipleOctaves: false,
      includingChromaticNotes: true,
      limitingNotesTo: .entireOctave
    )

    #expect(dFlatMajorLevel.id == 42)
    #expect(dFlatMajorLevel.key == .dFlat)
    #expect(dFlatMajorLevel.isMajor == true)
    #expect(dFlatMajorLevel.spansMultipleOctaves == false)
    #expect(dFlatMajorLevel.range == .entireOctave)
    #expect(dFlatMajorLevel.sessions.isEmpty == true)
    #expect(
      dFlatMajorLevel.notes == [
        Note(name: .dFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .eFlat, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .gFlat, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .aFlat, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
      ])
    #expect(
      dFlatMajorLevel.cadence
        == Cadence(
          voices: [.dFlat, .f, .aFlat],
          roots: [.dFlat, .gFlat, .aFlat, .dFlat],
          movement: [
            [0, 0, 0],
            [0, 1, 2],
            [-1, -2, 0],
            [0, 0, 0],
          ]
        ))
  }

  // MARK: - Minor

  @Test
  func makeFirstHalfMinorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let fMinorLevel = generator.makeLevel(
      withId: 42,
      inMinorKey: .f,
      spanningMultipleOctaves: false,
      includingChromaticNotes: false,
      limitingNotesTo: .firstHalfOfOctave
    )

    #expect(fMinorLevel.id == 42)
    #expect(fMinorLevel.key == .f)
    #expect(fMinorLevel.isMinor == true)
    #expect(fMinorLevel.spansMultipleOctaves == false)
    #expect(fMinorLevel.range == .firstHalfOfOctave)
    #expect(fMinorLevel.sessions.isEmpty == true)
    #expect(
      fMinorLevel.notes == [
        Note(name: .f, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .aFlat, octave: 1),
        Note(name: .bFlat, octave: 1),
      ])
    #expect(
      fMinorLevel.cadence
        == Cadence(
          voices: [.f, .aFlat, .c],
          roots: [.f, .bFlat, .c, .f],
          movement: [
            [0, 0, 0],
            [0, 2, 1],
            [-1, -1, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeSecondHalfMinorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let fMinorLevel = generator.makeLevel(
      withId: 42,
      inMinorKey: .f,
      spanningMultipleOctaves: false,
      includingChromaticNotes: false,
      limitingNotesTo: .secondHalfOfOctave
    )

    #expect(fMinorLevel.id == 42)
    #expect(fMinorLevel.key == .f)
    #expect(fMinorLevel.isMinor == true)
    #expect(fMinorLevel.spansMultipleOctaves == false)
    #expect(fMinorLevel.range == .secondHalfOfOctave)
    #expect(fMinorLevel.sessions.isEmpty == true)
    #expect(
      fMinorLevel.notes == [
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
        Note(name: .e, octave: 2),
        Note(name: .f, octave: 2),
      ])
    #expect(
      fMinorLevel.cadence
        == Cadence(
          voices: [.f, .aFlat, .c],
          roots: [.f, .bFlat, .c, .f],
          movement: [
            [0, 0, 0],
            [0, 2, 1],
            [-1, -1, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeEntireOctaveMinorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let fMinorLevel = generator.makeLevel(
      withId: 42,
      inMinorKey: .f,
      spanningMultipleOctaves: false,
      includingChromaticNotes: false,
      limitingNotesTo: .entireOctave
    )

    #expect(fMinorLevel.id == 42)
    #expect(fMinorLevel.key == .f)
    #expect(fMinorLevel.isMinor == true)
    #expect(fMinorLevel.spansMultipleOctaves == false)
    #expect(fMinorLevel.range == .entireOctave)
    #expect(fMinorLevel.sessions.isEmpty == true)
    #expect(
      fMinorLevel.notes == [
        Note(name: .f, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .aFlat, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
        Note(name: .e, octave: 2),
        Note(name: .f, octave: 2),
      ])
    #expect(
      fMinorLevel.cadence
        == Cadence(
          voices: [.f, .aFlat, .c],
          roots: [.f, .bFlat, .c, .f],
          movement: [
            [0, 0, 0],
            [0, 2, 1],
            [-1, -1, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeFirstHalfChromaticMinorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let fMinorLevel = generator.makeLevel(
      withId: 42,
      inMinorKey: .f,
      spanningMultipleOctaves: false,
      includingChromaticNotes: true,
      limitingNotesTo: .firstHalfOfOctave
    )

    #expect(fMinorLevel.id == 42)
    #expect(fMinorLevel.key == .f)
    #expect(fMinorLevel.isMinor == true)
    #expect(fMinorLevel.spansMultipleOctaves == false)
    #expect(fMinorLevel.range == .firstHalfOfOctave)
    #expect(fMinorLevel.sessions.isEmpty == true)
    #expect(
      fMinorLevel.notes == [
        Note(name: .f, octave: 1),
        Note(name: .fSharp, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .aFlat, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .bFlat, octave: 1),
      ])
    #expect(
      fMinorLevel.cadence
        == Cadence(
          voices: [.f, .aFlat, .c],
          roots: [.f, .bFlat, .c, .f],
          movement: [
            [0, 0, 0],
            [0, 2, 1],
            [-1, -1, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeSecondHalfChromaticMinorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let fMinorLevel = generator.makeLevel(
      withId: 42,
      inMinorKey: .f,
      spanningMultipleOctaves: false,
      includingChromaticNotes: true,
      limitingNotesTo: .secondHalfOfOctave
    )

    #expect(fMinorLevel.id == 42)
    #expect(fMinorLevel.key == .f)
    #expect(fMinorLevel.isMinor == true)
    #expect(fMinorLevel.spansMultipleOctaves == false)
    #expect(fMinorLevel.range == .secondHalfOfOctave)
    #expect(fMinorLevel.sessions.isEmpty == true)
    #expect(
      fMinorLevel.notes == [
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
        Note(name: .e, octave: 2),
        Note(name: .f, octave: 2),
      ])
    #expect(
      fMinorLevel.cadence
        == Cadence(
          voices: [.f, .aFlat, .c],
          roots: [.f, .bFlat, .c, .f],
          movement: [
            [0, 0, 0],
            [0, 2, 1],
            [-1, -1, 0],
            [0, 0, 0],
          ]
        ))
  }

  @Test
  func makeEntireOctaveChromaticMinorLevel() async throws {
    let generator = DiatonicLevelGenerator()
    let fMinorLevel = generator.makeLevel(
      withId: 42,
      inMinorKey: .f,
      spanningMultipleOctaves: false,
      includingChromaticNotes: true,
      limitingNotesTo: .entireOctave
    )

    #expect(fMinorLevel.id == 42)
    #expect(fMinorLevel.key == .f)
    #expect(fMinorLevel.isMinor == true)
    #expect(fMinorLevel.spansMultipleOctaves == false)
    #expect(fMinorLevel.range == .entireOctave)
    #expect(fMinorLevel.sessions.isEmpty == true)
    #expect(
      fMinorLevel.notes == [
        Note(name: .f, octave: 1),
        Note(name: .fSharp, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .aFlat, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .dFlat, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
        Note(name: .e, octave: 2),
        Note(name: .f, octave: 2),
      ])
    #expect(
      fMinorLevel.cadence
        == Cadence(
          voices: [.f, .aFlat, .c],
          roots: [.f, .bFlat, .c, .f],
          movement: [
            [0, 0, 0],
            [0, 2, 1],
            [-1, -1, 0],
            [0, 0, 0],
          ]
        ))
  }
}
