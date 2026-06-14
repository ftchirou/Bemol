///
/// FileSessionStorage.swift
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

actor FileSessionStorage: SessionStorage {
  enum Error: Swift.Error {
    case unexpected
  }

  private let fileManager: FileManager

  init(fileManager: FileManager) {
    self.fileManager = fileManager
  }

  func saveSession(_ session: Session, level: Level) async throws {
    guard !session.score.isEmpty else { return }

    let directoryURL = try appDirectoryURL()
    let sessionsFile = URL(filePath: sessionsFileName(for: level), relativeTo: directoryURL)
    let sessionsFilePath = sessionsFile.pathComponents.joined(separator: "/")

    if !fileManager.fileExists(atPath: sessionsFilePath) {
      try "".write(to: sessionsFile, atomically: true, encoding: .utf8)
    }

    let score = session.score
      .map { ($0.key.name, $0.key.octave, $0.value.correct, $0.value.wrong) }
      .sorted(by: { $0.0 < $1.0 })
      .map { "\($0.0.toString()):\($0.1):\($0.2):\($0.3)" }
      .joined(separator: ",")

    guard let line = "\(session.timestamp);\(score)\n".data(using: .utf8) else {
      return
    }

    let fileHandle = try FileHandle(forUpdating: sessionsFile)

    try fileHandle.seekToEnd()
    try fileHandle.write(contentsOf: line)
    try fileHandle.close()
  }

  func loadSessions(for level: Level) async throws -> [Session] {
    let directoryURL = try appDirectoryURL()
    let sessionsFile = URL(filePath: sessionsFileName(for: level), relativeTo: directoryURL)
    let sessionsFilePath = sessionsFile.pathComponents.joined(separator: "/")

    guard fileManager.fileExists(atPath: sessionsFilePath) else {
      return []
    }

    let contents = try String(contentsOf: sessionsFile, encoding: .utf8)
    let lines = contents.components(separatedBy: .newlines)
      .filter { $0.count > 0 }
      .suffix(100)
    var sessions: [Session] = []

    for line in lines {
      let components = line.split(separator: ";")

      guard components.count == 2 else {
        continue
      }

      let timestamp = TimeInterval(components[0]) ?? 0
      var score: [Note: Score] = [:]

      for stat in components[1].split(separator: ",") {
        let noteAndValues = stat.split(separator: ":")

        guard noteAndValues.count == 4 else {
          continue
        }

        guard
          let noteName = NoteName.parse(noteAndValues[0], for: level.id),
          let noteOctave = UInt8(noteAndValues[1]),
          let correct = Int(noteAndValues[2]),
          let wrong = Int(noteAndValues[3])
        else {
          continue
        }

        score[Note(name: noteName, octave: noteOctave)] = Score(correct: correct, wrong: wrong)
      }

      if !score.isEmpty {
        sessions.append(Session(timestamp: timestamp, score: score))
      }
    }

    return sessions
  }

  private func sessionsFileName(for level: Level) -> String {
    "sessions_\(level.id).txt"
  }

  private func appDirectoryURL() throws -> URL {
    let url = try URL(
      fileURLWithPath: "bemol_sessions",
      isDirectory: true,
      relativeTo: fileManager.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
    )

    let path = url.pathComponents.joined(separator: "/")
    var isDirectory: ObjCBool = false
    let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)

    if exists && isDirectory.boolValue == true {
      return url
    }

    try fileManager.createDirectory(at: url, withIntermediateDirectories: false)

    return url
  }
}

extension NoteName {
  fileprivate static func parse(_ substring: Substring, for level: Int) -> NoteName? {
    switch substring.lowercased() {
    case "c": .c
    case "csharp", "dflat": .cSharp
    case "d": .d
    case "dsharp", "eflat": .dSharp
    case "e": .e
    case "f": .f
    case "fsharp", "gflat": .fSharp
    case "g": .g
    case "gsharp", "aflat": .gSharp
    case "a": .a
    case "asharp", "bflat": .aSharp
    case "b": .b
    default: nil
    }
  }

  fileprivate func toString() -> String {
    switch self {
    case .c: "c"
    case .cSharp: "csharp"
    case .d: "d"
    case .dSharp: "dsharp"
    case .e: "e"
    case .f: "f"
    case .fSharp: "fsharp"
    case .g: "g"
    case .gSharp: "gsharp"
    case .a: "a"
    case .aSharp: "asharp"
    case .b: "b"
    }
  }
}
