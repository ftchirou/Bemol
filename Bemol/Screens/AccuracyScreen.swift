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

struct AccuracyScreenDelegate {
  let didPressDone: () -> Void
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
    bar.delegate = TitleBarDelegate(
      didPressCancelButton: { [weak self] in self?.didPressCancelButton() },
      didPressDoneButton: { [weak self] in self?.didPressDoneButton() }
    )

    return bar
  }()

  private lazy var keyboardView: KeyboardView = {
    let keyboardView = KeyboardView(range: 1...2)
    keyboardView.translatesAutoresizingMaskIntoConstraints = false
    keyboardView.setEnabledForAllKeys(false)
    keyboardView.setTintForAllNotes(nil)
    keyboardView.isScrollEnabled = false
    keyboardView.delegate = KeyboardViewDelegate(
      didPressNote: { [weak self] in self?.didPressNote($0) },
      didReleaseNote: { [weak self] in self?.didReleaseNote($0) }
    )
    return keyboardView
  }()

  // MARK: - Formatters

  private lazy var percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent

    return formatter
  }()

  // MARK: - API

  var delegate: AccuracyScreenDelegate?

  var state: AccuracyScreenState? = nil {
    didSet {
      let activeNotes = state?.activeNotes ?? []

      if oldValue == nil || activeNotes != oldValue?.activeNotes ?? [] {
        keyboardView.scrollTo(note: Note(name: state?.key ?? .c, octave: 1))
        keyboardView.setLabelForAllNotes(nil)
        keyboardView.setTintForAllNotes(nil)
        accuracy = state?.accuracyPerNote ?? [:]
        keyboardView.setEnabledForAllKeys(false)
        keyboardView.setEnabled(true, for: (state?.activeNotes ?? []))
      }

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
      titleBar.heightAnchor.constraint(
        equalTo: view.heightAnchor,
        multiplier: titleBarHeightMultiplier()
      ),

      keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      keyboardView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
      keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    return view
  }()

  // MARK: - Properties

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

  // MARK: - Private Helpers

  private func titleBarHeightMultiplier() -> CGFloat {
    switch (
      titleBar.traitCollection.verticalSizeClass,
      titleBar.traitCollection.horizontalSizeClass
    ) {
    case (.regular, .regular):
      0.10
    default:
      0.20
    }
  }
}

// MARK: - TitleBarDelegate

extension AccuracyScreen {
  func didPressDoneButton() {
    delegate?.didPressDone()
  }

  func didPressCancelButton() {}
}

// MARK: - KeyboardViewDelegate

extension AccuracyScreen {
  func didPressNote(_ note: Note) {
    Task {
      try await notePlayer.playNote(note)
    }
  }

  func didReleaseNote(_ note: Note) {
  }
}
