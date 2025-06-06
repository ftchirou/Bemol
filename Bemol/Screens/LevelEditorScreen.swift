///
/// ErrorScreen.swift
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

struct LevelEditorScreenDelegate {
  let didCancel: () -> Void
  let didSelectNotes: ([Note]) -> Void
}

struct LevelEditorScreenState {
  var key: NoteName = .c
  var allNotes: [Note]
  var selectedNotes: [Note]
}

@MainActor
final class LevelEditorScreen {
  // MARK: - Views

  private lazy var titleBar: TitleBar = {
    let bar = TitleBar()
    bar.translatesAutoresizingMaskIntoConstraints = false
    bar.title = AttributedString(String(localized: "selectNotes"))
    bar.delegate = TitleBarDelegate(
      didPressCancelButton: { [weak self] in self?.didPressCancelButton() },
      didPressDoneButton: { [weak self] in self?.didPressDoneButton() }
    )

    return bar
  }()

  private lazy var keyboardView: KeyboardView = {
    let keyboardView = KeyboardView(range: range)
    keyboardView.translatesAutoresizingMaskIntoConstraints = false
    keyboardView.isScrollEnabled = false
    keyboardView.delegate = KeyboardViewDelegate(
      didPressNote: { [weak self] in self?.didPressNote($0) },
      didReleaseNote: { [weak self] in self?.didReleaseNote($0) }
    )

    return keyboardView
  }()

  // MARK: - API

  var delegate: LevelEditorScreenDelegate?

  var state: LevelEditorScreenState? = nil {
    didSet {
      let key = state?.key ?? .c
      let oldKey = oldValue?.key ?? .c

      let notes = state?.selectedNotes ?? []
      let oldNotes = oldValue?.selectedNotes ?? []

      if oldValue == nil || key != oldKey || notes != oldNotes {
        keyboardView.scrollTo(note: Note(name: state?.key ?? .c, octave: 1))
        keyboardView.setLabelForAllNotes(nil)
        keyboardView.setEnabledForAllKeys(false)

        for note in state?.allNotes ?? [] {
          keyboardView.setLabel(note.name.letter, for: note)
          keyboardView.setEnabled(true, for: [note])
        }

        setNotes(notes)
      }
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

  private let range: ClosedRange<Octave> = 1...2
  private let notePlayer: NotePlayer
  private var selectedNotes: [Note] = []

  // MARK: - Initialization

  init(notePlayer: NotePlayer) {
    self.notePlayer = notePlayer
  }

  // MARK: - API

  func setNotes(_ notes: [Note]) {
    for note in selectedNotes {
      deselectNote(note)
    }

    selectedNotes.removeAll()

    for note in notes {
      selectNote(note)
      selectedNotes.append(note)
    }
  }

  // MARK: - Private Helpers

  private func selectNote(_ note: Note) {
    keyboardView.setTint(.systemTeal, for: note)
    keyboardView.setSelected(true, for: note)
  }

  private func deselectNote(_ note: Note) {
    keyboardView.setTint(nil, for: note)
    keyboardView.setSelected(false, for: note)
  }

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

extension LevelEditorScreen {
  func didPressCancelButton() {
    setNotes([])
    delegate?.didCancel()
  }

  func didPressDoneButton() {
    delegate?.didSelectNotes(selectedNotes)
  }
}

// MARK: - KeyboardViewDelegate

extension LevelEditorScreen {
  func didPressNote(_ note: Note) {
    if let index = selectedNotes.firstIndex(where: { $0 == note }) {
      deselectNote(note)
      selectedNotes.remove(at: index)
    } else {
      selectNote(note)
      selectedNotes.append(note)
    }

    titleBar.isDoneButtonEnabled = !selectedNotes.isEmpty

    Task {
      try await notePlayer.playNote(note)
    }
  }

  func didReleaseNote(_ note: Note) {
  }
}
