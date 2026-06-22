///
/// FileSessionStorageTests.swift
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
struct FileSessionStorageTests {
  @Test
  func loadSingleSession() async throws {
    let level = makeLevel(id: 1)
    let sessionsFile = try sessionsFileURL(for: level.id)
    try "1745827200;c:1:12:14,d:2:0:5,fSharp:1:4:45"
      .write(to: sessionsFile, atomically: true, encoding: .utf8)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    let sessions = try await sessionStorage.loadSessions(for: level)

    #expect(sessions.count == 1)

    let session = try #require(sessions.first)

    #expect(session.timestamp == 1_745_827_200)
    #expect(session.score.count == 3)
    #expect(session.score[Note(name: .c, octave: 1)] ?? .zero == .init(correct: 12, wrong: 14))
    #expect(session.score[Note(name: .d, octave: 2)] ?? .zero == .init(correct: 0, wrong: 5))
    #expect(session.score[Note(name: .gFlat, octave: 1)] ?? .zero == .init(correct: 4, wrong: 45))

    try? FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func loadMultipleSessions() async throws {
    let level = makeLevel(id: 2)
    let sessionsFile = try sessionsFileURL(for: level.id)
    try """
    1745827200;c:1:12:14,d:2:0:5,fSharp:1:4:45
    1745827300;g:1:15:9,fSharp:2:4:3,dFlat:1:8:24,e:2:1:0
    1745827400;a:1:10:0,c:2:50:24,b:2:41:20
    """.write(to: sessionsFile, atomically: true, encoding: .utf8)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    let sessions = try await sessionStorage.loadSessions(for: level)

    #expect(sessions.count == 3)

    let first = sessions[0]
    #expect(first.timestamp == 1_745_827_200)
    #expect(first.score.count == 3)
    #expect(first.score[Note(name: .c, octave: 1)] ?? .zero == .init(correct: 12, wrong: 14))
    #expect(first.score[Note(name: .d, octave: 2)] ?? .zero == .init(correct: 0, wrong: 5))
    #expect(first.score[Note(name: .gFlat, octave: 1)] ?? .zero == .init(correct: 4, wrong: 45))

    let second = sessions[1]
    #expect(second.timestamp == 1_745_827_300)
    #expect(second.score.count == 4)
    #expect(second.score[Note(name: .g, octave: 1)] ?? .zero == .init(correct: 15, wrong: 9))
    #expect(second.score[Note(name: .fSharp, octave: 2)] ?? .zero == .init(correct: 4, wrong: 3))
    #expect(second.score[Note(name: .dFlat, octave: 1)] ?? .zero == .init(correct: 8, wrong: 24))
    #expect(second.score[Note(name: .e, octave: 2)] ?? .zero == .init(correct: 1, wrong: 0))

    let third = sessions[2]
    #expect(third.timestamp == 1_745_827_400)
    #expect(third.score.count == 3)
    #expect(third.score[Note(name: .a, octave: 1)] ?? .zero == .init(correct: 10, wrong: 0))
    #expect(third.score[Note(name: .c, octave: 2)] ?? .zero == .init(correct: 50, wrong: 24))
    #expect(third.score[Note(name: .b, octave: 2)] ?? .zero == .init(correct: 41, wrong: 20))

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func loadSessionSkipsInvalidNote() async throws {
    let level = makeLevel(id: 3)
    let sessionsFile = try sessionsFileURL(for: level.id)
    try "1745827200;c:1:12:14,x:1:32:32,d:2:0:5,z:8:12:43,e:1:4:45"
      .write(to: sessionsFile, atomically: true, encoding: .utf8)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    let sessions = try await sessionStorage.loadSessions(for: level)

    #expect(sessions.count == 1)

    let session = try #require(sessions.first)

    #expect(session.timestamp == 1_745_827_200)
    #expect(session.score.count == 3)
    #expect(session.score[Note(name: .c, octave: 1)] ?? .zero == .init(correct: 12, wrong: 14))
    #expect(session.score[Note(name: .d, octave: 2)] ?? .zero == .init(correct: 0, wrong: 5))
    #expect(session.score[Note(name: .e, octave: 1)] ?? .zero == .init(correct: 4, wrong: 45))

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func loadSessionSkipsMalformedSessions() async throws {
    let level = makeLevel(id: 4)
    let sessionsFile = try sessionsFileURL(for: level.id)
    try """
    1745827200;c:1:12:14,d:2:0:5,fSharp:1:4:45
    1745827500;c
    1745827300;g:1:15:9,fSharp:2:4:3,dFlat:1:8:24,e:2:1:0
    1745827400    ;    x   : 98    +  a
    1745827400;a:1:10:0,c:2:50:24,b:2:41:20
    some random string here
    """.write(to: sessionsFile, atomically: true, encoding: .utf8)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    let sessions = try await sessionStorage.loadSessions(for: level)

    #expect(sessions.count == 3)

    let first = sessions[0]
    #expect(first.timestamp == 1_745_827_200)
    #expect(first.score.count == 3)
    #expect(first.score[Note(name: .c, octave: 1)] ?? .zero == .init(correct: 12, wrong: 14))
    #expect(first.score[Note(name: .d, octave: 2)] ?? .zero == .init(correct: 0, wrong: 5))
    #expect(first.score[Note(name: .gFlat, octave: 1)] ?? .zero == .init(correct: 4, wrong: 45))

    let second = sessions[1]
    #expect(second.timestamp == 1_745_827_300)
    #expect(second.score.count == 4)
    #expect(second.score[Note(name: .g, octave: 1)] ?? .zero == .init(correct: 15, wrong: 9))
    #expect(second.score[Note(name: .fSharp, octave: 2)] ?? .zero == .init(correct: 4, wrong: 3))
    #expect(second.score[Note(name: .dFlat, octave: 1)] ?? .zero == .init(correct: 8, wrong: 24))
    #expect(second.score[Note(name: .e, octave: 2)] ?? .zero == .init(correct: 1, wrong: 0))

    let third = sessions[2]
    #expect(third.timestamp == 1_745_827_400)
    #expect(third.score.count == 3)
    #expect(third.score[Note(name: .a, octave: 1)] ?? .zero == .init(correct: 10, wrong: 0))
    #expect(third.score[Note(name: .c, octave: 2)] ?? .zero == .init(correct: 50, wrong: 24))
    #expect(third.score[Note(name: .b, octave: 2)] ?? .zero == .init(correct: 41, wrong: 20))

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func loadSessionCorrectlyParsesAllNotes() async throws {
    let level = makeLevel(id: 5)
    let sessionsFile = try sessionsFileURL(for: level.id)
    try """
    1745827200;c:1:1:0,cSharp:1:1:0,d:1:1:0,dSharp:1:1:0,e:1:1:0,f:1:1:0,fSharp:1:1:0,g:1:1:0,gSharp:1:1:0,a:1:1:0,aSharp:1:1:0,b:1:1:0,
    """.write(to: sessionsFile, atomically: true, encoding: .utf8)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    let sessions = try await sessionStorage.loadSessions(for: level)

    #expect(sessions.count == 1)

    let session = try #require(sessions.first)

    for note in NoteName.all {
      #expect(session.score[Note(name: note, octave: 1)] ?? .zero == .init(correct: 1, wrong: 0))
    }

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func loadSessionCorrectlyParsesAllNotesWithAlternateNaming() async throws {
    let level = makeLevel(id: 6)
    let sessionsFile = try sessionsFileURL(for: level.id)
    try """
    1745827200;c:1:1:0,dFlat:1:1:0,d:1:1:0,eFlat:1:1:0,e:1:1:0,f:1:1:0,gFlat:1:1:0,g:1:1:0,aFlat:1:1:0,a:1:1:0,bFlat:1:1:0,b:1:1:0,
    """.write(to: sessionsFile, atomically: true, encoding: .utf8)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    let sessions = try await sessionStorage.loadSessions(for: level)

    #expect(sessions.count == 1)

    let session = try #require(sessions.first)

    for note in NoteName.all {
      #expect(session.score[Note(name: note, octave: 1)] ?? .zero == .init(correct: 1, wrong: 0))
    }

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func loadSessionCorrectlyParsesAllNotesWithInconsistentCasing() async throws {
    let level = makeLevel(id: 7)
    let sessionsFile = try sessionsFileURL(for: level.id)
    try """
    1745827200;C:1:1:0,cShaRp:1:1:0,d:1:1:0,eFLAT:1:1:0,e:1:1:0,f:1:1:0,FSHARP:1:1:0,g:1:1:0,gsharP:1:1:0,a:1:1:0,BFLaT:1:1:0,b:1:1:0,
    """.write(to: sessionsFile, atomically: true, encoding: .utf8)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    let sessions = try await sessionStorage.loadSessions(for: level)

    #expect(sessions.count == 1)

    let session = try #require(sessions.first)

    for note in NoteName.all {
      #expect(session.score[Note(name: note, octave: 1)] ?? .zero == .init(correct: 1, wrong: 0))
    }

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func saveSession() async throws {
    let now: TimeInterval = 1745827200.0
    let level = makeLevel(id: 42)
    let session = Session(
      timestamp: now,
      score: [
        Note(name: .c, octave: 1): .init(correct: 12, wrong: 34),
        Note(name: .bFlat, octave: 1): .init(correct: 32, wrong: 45),
        Note(name: .d, octave: 2): .init(correct: 0, wrong: 32),
      ]
    )

    let sessionStorage = FileSessionStorage(fileManager: .default)
    try await sessionStorage.saveSession(session, level: level)

    let sessionsFile = try sessionsFileURL(for: level.id)
    let contents = try String(contentsOf: sessionsFile, encoding: .utf8)
    #expect(contents == "1745827200.0;c:1:12:34,d:2:0:32,asharp:1:32:45\n")

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func saveMultipleSessions() async throws {
    let now: TimeInterval = 1745827200.0
    let level = makeLevel(id: 43)
    let sessions: [Session] = [
      Session(
        timestamp: now,
        score: [
          Note(name: .c, octave: 1): .init(correct: 12, wrong: 34),
          Note(name: .bFlat, octave: 1): .init(correct: 32, wrong: 45),
          Note(name: .d, octave: 2): .init(correct: 0, wrong: 32),
        ]
      ),
      Session(
        timestamp: now + 100,
        score: [
          Note(name: .aFlat, octave: 1): .init(correct: 1, wrong: 94),
          Note(name: .d, octave: 2): .init(correct: 0, wrong: 43),
          Note(name: .b, octave: 1): .init(correct: 1, wrong: 4),
        ]
      ),
      Session(
        timestamp: now + 200,
        score: [
          Note(name: .c, octave: 1): .init(correct: 1, wrong: 3),
          Note(name: .d, octave: 1): .init(correct: 4, wrong: 21),
        ]
      ),
    ]

    let sessionStorage = FileSessionStorage(fileManager: .default)

    for session in sessions {
      try await sessionStorage.saveSession(session, level: level)
    }

    let sessionsFile = try sessionsFileURL(for: level.id)
    let contents = try String(contentsOf: sessionsFile, encoding: .utf8)
    #expect(
      contents == [
        "1745827200.0;c:1:12:34,d:2:0:32,asharp:1:32:45",
        "1745827300.0;d:2:0:43,gsharp:1:1:94,b:1:1:4",
        "1745827400.0;c:1:1:3,d:1:4:21",
      ].joined(separator: "\n") + "\n")

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func saveSessionSkipsSessionsWithEmptyScore() async throws {
    let now: TimeInterval = 1745827200.0
    let level = makeLevel(id: 44)
    let sessions: [Session] = [
      Session(
        timestamp: now,
        score: [
          Note(name: .c, octave: 1): .init(correct: 12, wrong: 34),
          Note(name: .bFlat, octave: 1): .init(correct: 32, wrong: 45),
          Note(name: .d, octave: 2): .init(correct: 0, wrong: 32),
        ]
      ),
      Session(
        timestamp: now + 100,
        score: [
          Note(name: .aFlat, octave: 1): .init(correct: 1, wrong: 94),
          Note(name: .d, octave: 2): .init(correct: 0, wrong: 43),
          Note(name: .b, octave: 1): .init(correct: 1, wrong: 4),
        ]
      ),
      Session(
        timestamp: now + 400,
        score: [:]
      ),
      Session(
        timestamp: now + 200,
        score: [
          Note(name: .c, octave: 1): .init(correct: 1, wrong: 3),
          Note(name: .d, octave: 1): .init(correct: 4, wrong: 21),
        ]
      ),
      Session(
        timestamp: now + 500,
        score: [:]
      ),
    ]

    let sessionStorage = FileSessionStorage(fileManager: .default)

    for session in sessions {
      try await sessionStorage.saveSession(session, level: level)
    }

    let sessionsFile = try sessionsFileURL(for: level.id)
    let contents = try String(contentsOf: sessionsFile, encoding: .utf8)
    #expect(
      contents == [
        "1745827200.0;c:1:12:34,d:2:0:32,asharp:1:32:45",
        "1745827300.0;d:2:0:43,gsharp:1:1:94,b:1:1:4",
        "1745827400.0;c:1:1:3,d:1:4:21",
      ].joined(separator: "\n") + "\n")

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func saveSessionCorrectlyWritesAllNotes() async throws {
    let now: TimeInterval = 1745827200.0
    let level = makeLevel(id: 45)

    let notes: [NoteName] = [
      .c, .cSharp, .d, .dSharp, .e, .f, .fSharp, .g, .gSharp, .a, .aSharp, .b,
    ]
    var score: [Note: Score] = [:]
    notes.forEach { score[Note(name: $0, octave: 1)] = .init(correct: 1, wrong: 0) }

    let session = Session(timestamp: now, score: score)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    try await sessionStorage.saveSession(session, level: level)

    let sessionsFile = try sessionsFileURL(for: level.id)
    let contents = try String(contentsOf: sessionsFile, encoding: .utf8)
    #expect(
      contents
        == "1745827200.0;c:1:1:0,csharp:1:1:0,d:1:1:0,dsharp:1:1:0,e:1:1:0,f:1:1:0,fsharp:1:1:0,g:1:1:0,gsharp:1:1:0,a:1:1:0,asharp:1:1:0,b:1:1:0\n"
    )

    try FileManager.default.removeItem(at: sessionsFile)
  }

  @Test
  func saveSessionCorrectlyWritesAllNotesWithAlternateNaming() async throws {
    let now: TimeInterval = 1745827200.0
    let level = makeLevel(id: 46)

    let notes: [NoteName] = [.c, .dFlat, .d, .eFlat, .e, .f, .gFlat, .g, .aFlat, .a, .bFlat, .b]
    var score: [Note: Score] = [:]
    notes.forEach { score[Note(name: $0, octave: 1)] = .init(correct: 1, wrong: 0) }

    let session = Session(timestamp: now, score: score)

    let sessionStorage = FileSessionStorage(fileManager: .default)
    try await sessionStorage.saveSession(session, level: level)

    let sessionsFile = try sessionsFileURL(for: level.id)
    let contents = try String(contentsOf: sessionsFile, encoding: .utf8)
    #expect(
      contents
        == "1745827200.0;c:1:1:0,csharp:1:1:0,d:1:1:0,dsharp:1:1:0,e:1:1:0,f:1:1:0,fsharp:1:1:0,g:1:1:0,gsharp:1:1:0,a:1:1:0,asharp:1:1:0,b:1:1:0\n"
    )

    try FileManager.default.removeItem(at: sessionsFile)
  }

  // MARK: - Private Helpers

  private func makeLevel(id: Int) -> Level {
    Level(
      id: id,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .firstHalfOfOctave,
      sessions: []
    )
  }

  private func sessionsDirURL() throws -> URL {
    try URL(
      fileURLWithPath: "bemol_sessions",
      isDirectory: true,
      relativeTo: FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
    )
  }

  private func sessionsFileURL(for levelId: Int) throws -> URL {
    let directoryURL = try sessionsDirURL()
    let path = directoryURL.pathComponents.joined(separator: "/")
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)

    if !exists || isDirectory.boolValue == false {
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    return URL(fileURLWithPath: "sessions_\(levelId).txt", relativeTo: directoryURL)
  }
}
