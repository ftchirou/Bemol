///
/// MockNotePlayer.swift
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

@testable import Bemol

final class MockNotePlayer: NotePlayer {
  var isPrepareToPlayCalled = false
  var isPlayNoteCalled = false
  var isPlayCadenceCalled = false
  var playedNote: Note?

  func prepareToPlay() async throws {
    isPrepareToPlayCalled = true
  }

  func playNote(_ note: Note) async throws {
    isPlayNoteCalled = true
    playedNote = note
  }

  func playCadence(_ cadence: Cadence) async throws {
    isPlayCadenceCalled = true
  }

  func getPlayedNote() async -> Note? {
    playedNote
  }
}
