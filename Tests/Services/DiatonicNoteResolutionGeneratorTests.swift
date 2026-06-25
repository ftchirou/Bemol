///
/// DiatonicNoteResolutionGeneratorTests.swift
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
struct DiatonicNoteResolutionGeneratorTests {
  // MARK: - Major

  @Test
  func testResolutionForNotesInCMajor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .c, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: false
    )
    let second = generator.resolution(
      for: Note(name: .d, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: false
    )
    let third = generator.resolution(
      for: Note(name: .e, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: false
    )
    let fourth = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: false
    )

    #expect(
      first == [
        Note(name: .c, octave: 1)
      ])
    #expect(
      second == [
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      third == [
        Note(name: .e, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .f, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])

    let fifth = generator.resolution(
      for: Note(name: .g, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: false
    )
    let sixth = generator.resolution(
      for: Note(name: .a, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: false
    )
    let seventh = generator.resolution(
      for: Note(name: .b, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: false
    )
    let nextFirst = generator.resolution(
      for: Note(name: .c, octave: 2),
      inMajorKey: .c,
      includingChromaticNotes: false
    )

    #expect(
      fifth == [
        Note(name: .g, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      sixth == [
        Note(name: .a, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      seventh == [
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .c, octave: 2)
      ])
  }

  @Test
  func testResolutionForNotesInChromaticCMajor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .c, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let minorSecond = generator.resolution(
      for: Note(name: .cSharp, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let second = generator.resolution(
      for: Note(name: .d, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let minorThird = generator.resolution(
      for: Note(name: .eFlat, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let third = generator.resolution(
      for: Note(name: .e, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let fourth = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )

    #expect(
      first == [
        Note(name: .c, octave: 1)
      ])
    #expect(
      minorSecond == [
        Note(name: .cSharp, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      second == [
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      minorThird == [
        Note(name: .eFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      third == [
        Note(name: .e, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .f, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])

    let diminishedFifth = generator.resolution(
      for: Note(name: .gFlat, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let fifth = generator.resolution(
      for: Note(name: .g, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let augmentedFifth = generator.resolution(
      for: Note(name: .gSharp, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let sixth = generator.resolution(
      for: Note(name: .a, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let minorSeventh = generator.resolution(
      for: Note(name: .bFlat, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let seventh = generator.resolution(
      for: Note(name: .b, octave: 1),
      inMajorKey: .c,
      includingChromaticNotes: true
    )
    let nextFirst = generator.resolution(
      for: Note(name: .c, octave: 2),
      inMajorKey: .c,
      includingChromaticNotes: true
    )

    #expect(
      diminishedFifth == [
        Note(name: .gFlat, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      fifth == [
        Note(name: .g, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      augmentedFifth == [
        Note(name: .gSharp, octave: 1),
        Note(name: .a, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      sixth == [
        Note(name: .a, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      minorSeventh == [
        Note(name: .bFlat, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      seventh == [
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .c, octave: 2)
      ])
  }

  @Test
  func testResolutionForNotesInEFlatMajor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .eFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )
    let second = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )
    let third = generator.resolution(
      for: Note(name: .g, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )
    let fourth = generator.resolution(
      for: Note(name: .aFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )

    #expect(
      first == [
        Note(name: .eFlat, octave: 1)
      ])
    #expect(
      second == [
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      third == [
        Note(name: .g, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .aFlat, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])

    let fifth = generator.resolution(
      for: Note(name: .bFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )
    let sixth = generator.resolution(
      for: Note(name: .c, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )
    let seventh = generator.resolution(
      for: Note(name: .d, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )
    let nextFirst = generator.resolution(
      for: Note(name: .eFlat, octave: 2),
      inMajorKey: .eFlat,
      includingChromaticNotes: false
    )

    #expect(
      fifth == [
        Note(name: .bFlat, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      sixth == [
        Note(name: .c, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      seventh == [
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .eFlat, octave: 2)
      ])
  }

  @Test
  func testResolutionForNotesInChromaticEFlatMajor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .eFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let minorSecond = generator.resolution(
      for: Note(name: .e, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let second = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let minorThird = generator.resolution(
      for: Note(name: .gFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let third = generator.resolution(
      for: Note(name: .g, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let fourth = generator.resolution(
      for: Note(name: .aFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )

    #expect(
      first == [
        Note(name: .eFlat, octave: 1)
      ])
    #expect(
      minorSecond == [
        Note(name: .e, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      second == [
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      minorThird == [
        Note(name: .gFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      third == [
        Note(name: .g, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .aFlat, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])

    let diminishedFifth = generator.resolution(
      for: Note(name: .a, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let fifth = generator.resolution(
      for: Note(name: .bFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let augmentedFifth = generator.resolution(
      for: Note(name: .b, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let sixth = generator.resolution(
      for: Note(name: .c, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let minorSeventh = generator.resolution(
      for: Note(name: .dFlat, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let seventh = generator.resolution(
      for: Note(name: .d, octave: 1),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )
    let nextFirst = generator.resolution(
      for: Note(name: .eFlat, octave: 2),
      inMajorKey: .eFlat,
      includingChromaticNotes: true
    )

    #expect(
      diminishedFifth == [
        Note(name: .a, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      fifth == [
        Note(name: .bFlat, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      augmentedFifth == [
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      sixth == [
        Note(name: .c, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      minorSeventh == [
        Note(name: .dFlat, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      seventh == [
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .eFlat, octave: 2)
      ])
  }

  // MARK: - Minor

  @Test
  func testResolutionForNotesInCMinor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .c, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: false
    )
    let second = generator.resolution(
      for: Note(name: .d, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: false
    )
    let minorThird = generator.resolution(
      for: Note(name: .eFlat, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: false
    )
    let fourth = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: false
    )

    #expect(
      first == [
        Note(name: .c, octave: 1)
      ])
    #expect(
      second == [
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      minorThird == [
        Note(name: .eFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])

    let fifth = generator.resolution(
      for: Note(name: .g, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: false
    )
    let augmentedFifth = generator.resolution(
      for: Note(name: .gSharp, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: false
    )
    let raisedSixth = generator.resolution(
      for: Note(name: .b, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: false
    )
    let nextFirst = generator.resolution(
      for: Note(name: .c, octave: 2),
      inMinorKey: .c,
      includingChromaticNotes: false
    )

    #expect(
      fifth == [
        Note(name: .g, octave: 1),
        Note(name: .gSharp, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])

    #expect(
      augmentedFifth == [
        Note(name: .gSharp, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      raisedSixth == [
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      raisedSixth == [
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .c, octave: 2)
      ])
  }

  @Test
  func testResolutionForNotesInChromaticCMinor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .c, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let minorSecond = generator.resolution(
      for: Note(name: .dFlat, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let second = generator.resolution(
      for: Note(name: .d, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let minorThird = generator.resolution(
      for: Note(name: .eFlat, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let majorThird = generator.resolution(
      for: Note(name: .e, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let fourth = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )

    #expect(
      first == [
        Note(name: .c, octave: 1)
      ])
    #expect(
      minorSecond == [
        Note(name: .dFlat, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      second == [
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      minorThird == [
        Note(name: .eFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      majorThird == [
        Note(name: .e, octave: 1),
        Note(name: .eFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .c, octave: 1),
      ])

    let diminishedFifth = generator.resolution(
      for: Note(name: .gFlat, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let fifth = generator.resolution(
      for: Note(name: .g, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let augmentedFifth = generator.resolution(
      for: Note(name: .gSharp, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let sixth = generator.resolution(
      for: Note(name: .a, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let raisedSixth = generator.resolution(
      for: Note(name: .b, octave: 1),
      inMinorKey: .c,
      includingChromaticNotes: true
    )
    let nextFirst = generator.resolution(
      for: Note(name: .c, octave: 2),
      inMinorKey: .c,
      includingChromaticNotes: true
    )

    #expect(
      diminishedFifth == [
        Note(name: .gFlat, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .gSharp, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      fifth == [
        Note(name: .g, octave: 1),
        Note(name: .gSharp, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      augmentedFifth == [
        Note(name: .gSharp, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      sixth == [
        Note(name: .a, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      raisedSixth == [
        Note(name: .b, octave: 1),
        Note(name: .c, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .c, octave: 2)
      ])
  }

  @Test
  func testResolutionForNotesInEFlatMinor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .eFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )
    let second = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )
    let minorThird = generator.resolution(
      for: Note(name: .gFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )
    let fourth = generator.resolution(
      for: Note(name: .aFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )

    #expect(
      first == [
        Note(name: .eFlat, octave: 1)
      ])
    #expect(
      second == [
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      minorThird == [
        Note(name: .gFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .aFlat, octave: 1),
        Note(name: .gFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])

    let fifth = generator.resolution(
      for: Note(name: .bFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )
    let augmentedFifth = generator.resolution(
      for: Note(name: .b, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )
    let raisedSixth = generator.resolution(
      for: Note(name: .d, octave: 2),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )
    let nextFirst = generator.resolution(
      for: Note(name: .eFlat, octave: 2),
      inMinorKey: .eFlat,
      includingChromaticNotes: false
    )

    #expect(
      fifth == [
        Note(name: .bFlat, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      augmentedFifth == [
        Note(name: .b, octave: 1),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      raisedSixth == [
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .eFlat, octave: 2)
      ])
  }

  @Test
  func testResolutionForNotesInChromaticEFlatMinor() {
    let generator = DiatonicNoteResolutionGenerator()

    let first = generator.resolution(
      for: Note(name: .eFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let second = generator.resolution(
      for: Note(name: .f, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let minorThird = generator.resolution(
      for: Note(name: .gFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let majorThird = generator.resolution(
      for: Note(name: .g, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let fourth = generator.resolution(
      for: Note(name: .aFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )

    #expect(
      first == [
        Note(name: .eFlat, octave: 1)
      ])
    #expect(
      second == [
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      minorThird == [
        Note(name: .gFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      majorThird == [
        Note(name: .g, octave: 1),
        Note(name: .gFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])
    #expect(
      fourth == [
        Note(name: .aFlat, octave: 1),
        Note(name: .gFlat, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .eFlat, octave: 1),
      ])

    let diminishedFifth = generator.resolution(
      for: Note(name: .a, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let fifth = generator.resolution(
      for: Note(name: .bFlat, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let augmentedFifth = generator.resolution(
      for: Note(name: .b, octave: 1),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let sixth = generator.resolution(
      for: Note(name: .c, octave: 2),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let raisedSixth = generator.resolution(
      for: Note(name: .dFlat, octave: 2),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let seventh = generator.resolution(
      for: Note(name: .d, octave: 2),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )
    let nextFirst = generator.resolution(
      for: Note(name: .eFlat, octave: 2),
      inMinorKey: .eFlat,
      includingChromaticNotes: true
    )

    #expect(
      diminishedFifth == [
        Note(name: .a, octave: 1),
        Note(name: .bFlat, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      fifth == [
        Note(name: .bFlat, octave: 1),
        Note(name: .b, octave: 1),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      augmentedFifth == [
        Note(name: .b, octave: 1),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      sixth == [
        Note(name: .c, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      raisedSixth == [
        Note(name: .dFlat, octave: 2),
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      seventh == [
        Note(name: .d, octave: 2),
        Note(name: .eFlat, octave: 2),
      ])
    #expect(
      nextFirst == [
        Note(name: .eFlat, octave: 2)
      ])
  }
}
