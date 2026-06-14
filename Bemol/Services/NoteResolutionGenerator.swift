///
/// NoteResolutionGenerator.swift
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

protocol NoteResolutionGenerator {
  func resolution(
    for note: Note,
    inMajorKey key: NoteName,
    includingChromaticNotes includeChromaticNotes: Bool
  ) -> Resolution

  func resolution(
    for note: Note,
    inMinorKey key: NoteName,
    includingChromaticNotes includeChromaticNotes: Bool
  ) -> Resolution
}

// MARK: -

struct DiatonicNoteResolutionGenerator: NoteResolutionGenerator {
  func resolution(
    for note: Note,
    inMajorKey key: NoteName,
    includingChromaticNotes includeChromaticNotes: Bool
  ) -> Resolution {
    if includeChromaticNotes {
      note.resolutionInMajorChromatics(key)
    } else {
      note.resolutionInMajor(key)
    }
  }

  func resolution(
    for note: Note,
    inMinorKey key: NoteName,
    includingChromaticNotes includeChromaticNotes: Bool
  ) -> Resolution {
    if includeChromaticNotes {
      note.resolutionInMinorChromatics(key)
    } else {
      note.resolutionInMinor(key)
    }
  }
}

extension Note {
  fileprivate func resolutionInMajor(_ key: NoteName) -> Resolution {
    var firstPattern = [0, 2, 4, 5]
    var secondPattern = [7, 9, 11]
    let index = name.index(inKey: key)

    if !firstPattern.contains(index) {
      firstPattern.append(index)
      firstPattern.sort()
    }

    if !secondPattern.contains(index) {
      secondPattern.append(index)
      secondPattern.sort()
    }

    return resolution(key: key, firstPattern: firstPattern, secondPattern: secondPattern)
  }

  fileprivate func resolutionInMajorChromatics(_ key: NoteName) -> Resolution {
    var firstPattern = [0, 2, 4, 5]
    var secondPattern = [7, 9, 11]
    let index = name.index(inKey: key)

    if !firstPattern.contains(index) {
      firstPattern.append(index)
      firstPattern.sort()
    }

    if !secondPattern.contains(index) {
      secondPattern.append(index)
      secondPattern.sort()
    }

    return resolution(key: key, firstPattern: firstPattern, secondPattern: secondPattern)
  }

  fileprivate func resolutionInMinor(_ key: NoteName) -> Resolution {
    var firstPattern = [0, 2, 3, 5]
    var secondPattern = [7, 8, 11]
    let index = name.index(inKey: key)

    if !firstPattern.contains(index) {
      firstPattern.append(index)
      firstPattern.sort()
    }

    if !secondPattern.contains(index) {
      secondPattern.append(index)
      secondPattern.sort()
    }

    return resolution(key: key, firstPattern: firstPattern, secondPattern: secondPattern)
  }

  fileprivate func resolutionInMinorChromatics(_ key: NoteName) -> Resolution {
    var firstPattern = [0, 2, 3, 5]
    var secondPattern = [7, 8, 11]
    let index = name.index(inKey: key)

    if !firstPattern.contains(index) {
      firstPattern.append(index)
      firstPattern.sort()
    }

    if !secondPattern.contains(index) {
      secondPattern.append(index)
      secondPattern.sort()
    }

    return resolution(key: key, firstPattern: firstPattern, secondPattern: secondPattern)
  }

  fileprivate func resolution(
    key: NoteName,
    firstPattern: [Int],
    secondPattern: [Int]
  ) -> Resolution {
    if name == key {
      return [self]
    }

    let noteIndex = self.name.index(inKey: key)

    if noteIndex <= 5 {
      let index = firstPattern.firstIndex(of: noteIndex)!
      let resolution = firstPattern[...index]

      return resolution.reversed().map {
        let noteName = NoteName.note(at: $0, in: key)
        let positionInScale = UInt8(noteName.index(inKey: key))
        let octave = position(of: noteName, positionInScale: positionInScale, relativeTo: key)
        return Note(name: NoteName.note(at: $0, in: key), octave: octave)
      }
    }

    let index = secondPattern.firstIndex(of: noteIndex)!
    let resolution = secondPattern[index...]

    return resolution.map {
      let noteName = NoteName.note(at: $0, in: key)
      let positionInScale = UInt8(noteName.index(inKey: key))
      let octave = position(of: noteName, positionInScale: positionInScale, relativeTo: key)
      return Note(name: NoteName.note(at: $0, in: key), octave: octave)
    } + [Note(name: key, octave: 2)]
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
}
