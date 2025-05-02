///
/// AccuracyScreen.swift
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
import UIKit

@MainActor
protocol AccuracyScreenDelegate: AnyObject {
  func didPressDone()
}

struct AccuracyScreenState {
  enum Context {
    case session
    case level
  }

  var context: Context = .level
  var key: NoteName = .c
  var accuracyPerNote: [Note: Double]
  var activeNotes: [Note]
}

@MainActor
final class AccuracyScreen {
  // MARK: - Views

  private lazy var titleBar: TitleBar = {
    let bar = TitleBar()
    bar.translatesAutoresizingMaskIntoConstraints = false
    bar.isCancelButtonHidden = true
    bar.delegate = self

    return bar
  }()

  private lazy var keyboardView: KeyboardView = {
    let keyboardView = KeyboardView(range: range)
    keyboardView.translatesAutoresizingMaskIntoConstraints = false
    keyboardView.setEnabledForAllKeys(false)
    keyboardView.setTintForAllNotes(nil)
    keyboardView.isScrollEnabled = false
    keyboardView.delegate = self

    return keyboardView
  }()

  // MARK: - Formatters

  private lazy var percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent

    return formatter
  }()

  // MARK: - API

  weak var delegate: AccuracyScreenDelegate?

  var state: AccuracyScreenState? = nil {
    didSet {
      keyboardView.scrollTo(note: Note(name: state?.key ?? .c, octave: 1))
      keyboardView.setLabelForAllNotes(nil)
      keyboardView.setTintForAllNotes(nil)
      accuracy = state?.accuracyPerNote ?? [:]
      keyboardView.setEnabledForAllKeys(false)
      keyboardView.setEnabled(true, for: (state?.activeNotes ?? []))

      titleBar.title = state?.context == .level
        ? AttributedString(localized: "levelAccuracy")
        : AttributedString(localized: "sessionAccuracy")
    }
  }

  lazy var view: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(titleBar)
    view.addSubview(keyboardView)

    NSLayoutConstraint.activate([
      titleBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      titleBar.topAnchor.constraint(equalTo: view.topAnchor),
      titleBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      titleBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),

      keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      keyboardView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
      keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    return view
  }()

  // MARK: - Properties

  private let range: ClosedRange<Octave> = 1...2
  private let notePlayer: NotePlayer

  private var accuracy: [Note: Double] = [:] {
    didSet {
      for (note, percent) in accuracy {
        keyboardView.setTint(
          UIColor.color(for: percent),
          percent: percent,
          for: note
        )

        let noteName = note.name.letter
        let formattedPercent = percentFormatter.string(from: NSNumber(floatLiteral: percent)) ?? ""
        keyboardView.setLabel("\(noteName) \(formattedPercent)", for: note)
      }
    }
  }

  // MARK: - Initialization

  init(notePlayer: NotePlayer) {
    self.notePlayer = notePlayer
  }
}

// MARK: - MessageBarDelegate

extension AccuracyScreen: TitleBarDelegate {
  func didPressDoneButton() {
    delegate?.didPressDone()
  }

  func didPressCancelButton() {}
}

// MARK: - KeyboardViewDelegate

extension AccuracyScreen: KeyboardViewDelegate {
  func didPressNote(_ note: Note) {
    Task {
      try await notePlayer.playNote(note)
    }
  }

  func didReleaseNote(_ note: Note) {
  }
}
