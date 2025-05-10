///
/// NoteName.swift
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

enum NoteName: UInt8, Equatable {
  case c = 12
  case cSharp = 13
  case d = 14
  case dSharp = 15
  case e = 16
  case f = 17
  case fSharp = 18
  case g = 19
  case gSharp = 20
  case a = 21
  case aSharp = 22
  case b = 23

  static let dFlat: NoteName = .cSharp
  static let eFlat: NoteName = .dSharp
  static let eSharp: NoteName = .f
  static let fFlat: NoteName = .e
  static let gFlat: NoteName = .fSharp
  static let aFlat: NoteName = .gSharp
  static let bFlat: NoteName = .aSharp

  static let all: [NoteName] = [
    .c, .cSharp, .d, .dSharp, .e, .f, .fSharp, .g, .gSharp, .a, .aSharp, .b
  ]

  // MARK: - Indexing

  var index: Int {
    Int(rawValue - NoteName.c.rawValue)
  }

  func index(inKey key: NoteName) -> Int {
    if self < key {
      return Int(rawValue + 12 - key.rawValue)
    }

    return Int(rawValue - key.rawValue)
  }

  // MARK: - Intervals

  var majorThird: NoteName {
    NoteName(rawValue: add(rawValue, 4))!
  }

  var minorThird: NoteName {
    NoteName(rawValue: add(rawValue, 3))!
  }

  var fourth: NoteName {
    NoteName(rawValue: add(rawValue, 5))!
  }

  var fifth: NoteName {
    NoteName(rawValue: add(rawValue, 7))!
  }

  var step: NoteName {
    NoteName(rawValue: add(rawValue, 2))!
  }

  var stepDown: NoteName {
    NoteName(rawValue: sub(rawValue, 2))!
  }

  var halfStep: NoteName {
    NoteName(rawValue: add(rawValue, 1))!
  }

  var halfStepDown: NoteName {
    NoteName(rawValue: sub(rawValue, 1))!
  }

  var next: NoteName {
    halfStep
  }

  func halfSteps(_ count: UInt8) -> NoteName {
    NoteName(rawValue: add(rawValue, count))!
  }

  // MARK: -

  private func add(_ lhs: UInt8, _ rhs: UInt8) -> UInt8 {
    var result = lhs + rhs

    if result > NoteName.b.rawValue {
      result = (result % NoteName.b.rawValue) + (NoteName.c.rawValue - 1)
    }

    return result
  }

  private func sub(_ lhs: UInt8, _ rhs: UInt8) -> UInt8 {
    var result = lhs - rhs

    if result < NoteName.c.rawValue {
      result += NoteName.c.rawValue
    }

    return result
  }
}

// MARK: - Comparable

extension NoteName: Comparable {
  static func < (lhs: NoteName, rhs: NoteName) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

// MARK: - Key Indexing

extension NoteName {
  static func note(at index: Int, in key: NoteName) -> NoteName {
    var notes: [Int: NoteName] = [:]

    for note in NoteName.all {
      let i = note.index(inKey: key)
      notes[i] = note
    }

    return notes[index]!
  }
}

// MARK: - Human Readable Naming

extension NoteName {
  func solfege(inKey key: NoteName) -> String {
    return solfegeNames[index(inKey: key)]
  }

  var solfege: String {
    solfege(inKey: .c)
  }

  var letter: String {
    switch self {
    case .c:
      String(localized: "C")
    case .cSharp:
      "\(String(localized: "C"))♯ / \(String(localized: "D"))♭"
    case .d:
      String(localized: "D")
    case .dSharp:
      "\(String(localized: "D"))♯ / \(String(localized: "E"))♭"
    case .e:
      String(localized: "E")
    case .f:
      String(localized: "F")
    case .fSharp:
      "\(String(localized: "F"))♯ / \(String(localized: "G"))♭"
    case .g:
      String(localized: "G")
    case .gSharp:
      "\(String(localized: "G"))♯ / \(String(localized: "A"))♭"
    case .a:
      String(localized: "A")
    case .aSharp:
      "\(String(localized: "A"))♯ / \(String(localized: "B"))♭"
    case .b:
      String(localized: "B")
    }
  }
}

fileprivate let solfegeNames = [
  String(localized: "do").capitalized,
  "\(String(localized: "di").capitalized) / \(String(localized: "ra").capitalized)",
  String(localized: "re").capitalized,
  "\(String(localized: "ri").capitalized) / \(String(localized: "me").capitalized)",
  String(localized: "mi").capitalized,
  String(localized: "fa").capitalized,
  "\(String(localized: "fi").capitalized) / \(String(localized: "se").capitalized)",
  String(localized: "sol").capitalized,
  "\(String(localized: "si").capitalized) / \(String(localized: "le").capitalized)",
  String(localized: "la").capitalized,
  "\(String(localized: "li").capitalized) / \(String(localized: "te").capitalized)",
  String(localized: "ti").capitalized,
]
