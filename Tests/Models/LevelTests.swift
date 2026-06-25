import Foundation
import Testing

@testable import Bemol

@MainActor
struct LevelTests {
  @Test
  func summary() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [
        Note(name: .c, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .c, octave: 2),
      ],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: false,
      sessions: [
        Session(
          timestamp: 1000,
          score: [
            Note(name: .c, octave: 1): .init(correct: 4, wrong: 2),
            Note(name: .d, octave: 1): .init(correct: 3, wrong: 0),
            Note(name: .e, octave: 1): .init(correct: 0, wrong: 8),
            Note(name: .f, octave: 1): .init(correct: 4, wrong: 1),
            Note(name: .g, octave: 1): .init(correct: 0, wrong: 0),
            Note(name: .c, octave: 2): .init(correct: 2, wrong: 1),
          ]
        )
      ]
    )

    let summary = level.summary

    #expect(summary.averagePerNote.count == 5)
    #expect(Int(summary.average * 100) == 52)
    #expect(Int((summary.averagePerNote[Note(name: .c, octave: 1)] ?? 0) * 100) == 66)
    #expect(Int((summary.averagePerNote[Note(name: .d, octave: 1)] ?? 0) * 100) == 100)
    #expect(Int((summary.averagePerNote[Note(name: .e, octave: 1)] ?? 0) * 100) == 0)
    #expect(Int((summary.averagePerNote[Note(name: .f, octave: 1)] ?? 0) * 100) == 80)
    #expect(summary.averagePerNote[Note(name: .g, octave: 1)] == nil)
    #expect(Int((summary.averagePerNote[Note(name: .c, octave: 2)] ?? 0) * 100) == 66)
  }

  @Test
  func summaryWithMultipleSessions() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [
        Note(name: .c, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .f, octave: 1),
        Note(name: .g, octave: 1),
        Note(name: .c, octave: 2),
      ],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: false,
      sessions: [
        Session(
          timestamp: 1000,
          score: [
            Note(name: .c, octave: 1): .init(correct: 4, wrong: 2),
            Note(name: .e, octave: 1): .init(correct: 0, wrong: 8),
          ]
        ),
        Session(
          timestamp: 1100,
          score: [
            Note(name: .d, octave: 1): .init(correct: 3, wrong: 0),
            Note(name: .f, octave: 1): .init(correct: 4, wrong: 1),
          ]
        ),
        Session(
          timestamp: 1200,
          score: [
            Note(name: .g, octave: 1): .init(correct: 0, wrong: 0),
            Note(name: .c, octave: 2): .init(correct: 2, wrong: 1),
          ]
        ),
      ]
    )

    let summary = level.summary

    #expect(summary.averagePerNote.count == 5)
    #expect(Int(summary.average * 100) == 52)
    #expect(Int((summary.averagePerNote[Note(name: .c, octave: 1)] ?? 0) * 100) == 66)
    #expect(Int((summary.averagePerNote[Note(name: .d, octave: 1)] ?? 0) * 100) == 100)
    #expect(Int((summary.averagePerNote[Note(name: .e, octave: 1)] ?? 0) * 100) == 0)
    #expect(Int((summary.averagePerNote[Note(name: .f, octave: 1)] ?? 0) * 100) == 80)
    #expect(summary.averagePerNote[Note(name: .g, octave: 1)] == nil)
    #expect(Int((summary.averagePerNote[Note(name: .c, octave: 2)] ?? 0) * 100) == 66)
  }

  @Test
  func summaryWithNonScoredNotes() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [
        Note(name: .c, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .f, octave: 1),
      ],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: false,
      sessions: [
        Session(
          timestamp: 1000,
          score: [
            Note(name: .c, octave: 1): .init(correct: 5, wrong: 0),
            Note(name: .d, octave: 1): .init(correct: 6, wrong: 0),
          ]
        )
      ]
    )

    let summary = level.summary

    #expect(summary.averagePerNote.count == 2)
    #expect(Int(summary.average * 100) == 50)
    #expect(Int((summary.averagePerNote[Note(name: .c, octave: 1)] ?? 0) * 100) == 100)
    #expect(Int((summary.averagePerNote[Note(name: .d, octave: 1)] ?? 0) * 100) == 100)
    #expect(summary.averagePerNote[Note(name: .e, octave: 1)] == nil)
    #expect(summary.averagePerNote[Note(name: .f, octave: 1)] == nil)
  }

  @Test
  func updateNotes() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [
        Note(name: .c, octave: 1),
        Note(name: .d, octave: 1),
        Note(name: .e, octave: 1),
        Note(name: .f, octave: 1),
      ],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: false,
      sessions: [
        Session(
          timestamp: 1000,
          score: [
            Note(name: .c, octave: 1): .init(correct: 5, wrong: 0),
            Note(name: .d, octave: 1): .init(correct: 6, wrong: 0),
          ]
        )
      ]
    )
    let newLevel = level.withNotes([Note(name: .aFlat, octave: 2)])

    #expect(newLevel.id == level.id)
    #expect(newLevel.key == level.key)
    #expect(newLevel.isMajor == level.isMajor)
    #expect(newLevel.notes == [Note(name: .aFlat, octave: 2)])
    #expect(newLevel.cadence == level.cadence)
    #expect(newLevel.spansMultipleOctaves == level.spansMultipleOctaves)
    #expect(newLevel.range == level.range)
    #expect(newLevel.isCustom == true)
    #expect(newLevel.sessions.isEmpty == true)
  }

  @Test
  func updateSessions() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [Note(name: .aFlat, octave: 2)],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: false,
      sessions: [
        Session(
          timestamp: 1000,
          score: [
            Note(name: .c, octave: 1): .init(correct: 5, wrong: 0),
            Note(name: .d, octave: 1): .init(correct: 6, wrong: 0),
          ]
        )
      ]
    )
    let newLevel = level.withSessions([
      Session(timestamp: 1200, score: [Note(name: .bFlat, octave: 2): .init(correct: 1, wrong: 0)])
    ])

    #expect(newLevel.id == level.id)
    #expect(newLevel.key == level.key)
    #expect(newLevel.isMajor == level.isMajor)
    #expect(newLevel.notes == level.notes)
    #expect(newLevel.cadence == level.cadence)
    #expect(newLevel.spansMultipleOctaves == level.spansMultipleOctaves)
    #expect(newLevel.range == level.range)
    #expect(newLevel.isCustom == level.isCustom)
    #expect(newLevel.sessions.count == 1)

    let session = try #require(newLevel.sessions.first)

    #expect(session.timestamp == 1200.0)
    #expect(session.score[Note(name: .bFlat, octave: 2)] ?? .zero == .init(correct: 1, wrong: 0))
    #expect(session.score[Note(name: .c, octave: 1)] == nil)
    #expect(session.score[Note(name: .d, octave: 1)] == nil)
  }

  @Test
  func majorLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: false,
      sessions: []
    )

    #expect(level.title == "C major")
  }

  @Test
  func minorLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: false,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: false,
      sessions: []
    )

    #expect(level.title == "C minor")
  }

  @Test
  func majorMultiOctaveLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: true,
      range: .entireOctave,
      isCustom: false,
      sessions: []
    )

    #expect(level.title == "C major · 8..")
  }

  @Test
  func minorMultiOctaveLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: false,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: true,
      range: .entireOctave,
      isCustom: false,
      sessions: []
    )

    #expect(level.title == "C minor · 8..")
  }

  @Test
  func customMajorLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: true,
      sessions: []
    )

    #expect(level.title == "C major *")
  }

  @Test
  func customMinorLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: false,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: false,
      range: .entireOctave,
      isCustom: true,
      sessions: []
    )

    #expect(level.title == "C minor *")
  }

  @Test
  func customMultiOctaveMajorLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: true,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: true,
      range: .entireOctave,
      isCustom: true,
      sessions: []
    )

    #expect(level.title == "C major * · 8..")
  }

  @Test
  func customMinorMultiOctaveLevelTitle() async throws {
    let level = Level(
      id: 1,
      key: .c,
      isMajor: false,
      isChromatic: false,
      notes: [],
      cadence: Cadence(voices: [], roots: [], movement: []),
      spansMultipleOctaves: true,
      range: .entireOctave,
      isCustom: true,
      sessions: []
    )

    #expect(level.title == "C minor * · 8..")
  }
}
