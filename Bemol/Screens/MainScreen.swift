///
/// MainScreen.swift
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

struct MainScreenDelegate {
  let didPressHomeButton: () -> Void
  let didPressRandomButton: () -> Void
  let didPressStartStopButton: () -> Void
  let didPressRepeatButton: () -> Void
  let didPressNextButton: () -> Void
  let didPressPreviousButton: () -> Void
  let didPressProgressButton: () -> Void
  let didPressConfigureButton: () -> Void
  let didPressNote: (Note) -> Void
  let didReleaseNote: (Note) -> Void
}

@MainActor
final class MainScreen {
  // MARK: - Views

  private lazy var keyboardView: KeyboardView = {
    let keyboard = KeyboardView(range: 1...2)
    keyboard.translatesAutoresizingMaskIntoConstraints = false
    keyboard.setEnabledForAllKeys(false)
    keyboard.setTintForAllNotes(nil)
    keyboard.isScrollEnabled = false
    keyboard.delegate = KeyboardViewDelegate(
      didPressNote: { [weak self] in self?.didPressNote($0) },
      didReleaseNote: { [weak self] in self?.didReleaseNote($0) }
    )

    return keyboard
  }()

  private lazy var navBar: NavBar = {
    let bar = NavBar()
    bar.translatesAutoresizingMaskIntoConstraints = false
    bar.delegate = NavBarDelegate(
      didPressHomeButton: { [weak self] in self?.didPressHomeButton() },
      didPressRandomButton: { [weak self] in self?.didPressRandomButton() },
      didPressPreviousButton: { [weak self] in self?.didPressPreviousButton() },
      didPressNextButton: { [weak self] in self?.didPressNextButton() },
      didPressConfigureButton: { [weak self] in self?.didPressConfigureButton() },
      didPressStartStopButton: { [weak self] in self?.didPressStartStopButton() },
      didPressRepeatButton: { [weak self] in self?.didPressRepeatButton() },
      didPressProgressButton:  { [weak self] in self?.didPressProgressButton() }
    )

    return bar
  }()

  lazy var view: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(navBar)
    view.addSubview(keyboardView)

    NSLayoutConstraint.activate([
      navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      navBar.topAnchor.constraint(equalTo: view.topAnchor),
      navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      navBar.heightAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.heightAnchor,
        multiplier: 0.20
      ),

      keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      keyboardView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
      keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    return view
  }()

  // MARK: - API

  var delegate: MainScreenDelegate?

  var state: MainScreenState? = nil {
    didSet {
      let key = state?.key ?? .c
      let oldKey = oldValue?.key ?? .c

      let activeNotes = state?.activeNotes ?? []
      let oldActiveNotes = oldValue?.activeNotes ?? []

      navBar.state = state?.navBarState
      keyboardView.isUserInteractionEnabled = state?.isKeyboardEnabled ?? true

      if oldValue == nil || key != oldKey || activeNotes != oldActiveNotes {
        keyboardView.scrollTo(note: Note(name: key, octave: 1), animated: true)
        keyboardView.setEnabledForAllKeys(false)
        keyboardView.setLabelForAllNotes(nil)
        keyboardView.setEnabled(true, for: activeNotes)
        keyboardView.setLabels(activeNotes.map { $0.name.solfege(inKey: key) }, for: activeNotes)
      }

      if let oldHighlightedNote = oldValue?.highlightedNote {
        keyboardView.setTint(nil, for: [oldHighlightedNote.0])
      }

      if let highlightedNote = state?.highlightedNote {
        keyboardView.setTint(highlightedNote.1, for: [highlightedNote.0])
      }
    }
  }
}

// MARK: - KeyboardDelegate

extension MainScreen {
  func didPressNote(_ note: Note) {
    delegate?.didPressNote(note)
  }

  func didReleaseNote(_ note: Note) {
    delegate?.didReleaseNote(note)
  }
}

// MARK: - NavBarDelegate

extension MainScreen {
  func didPressHomeButton() {
    delegate?.didPressHomeButton()
  }

  func didPressRandomButton() {
    delegate?.didPressRandomButton()
  }

  func didPressStartStopButton() {
    delegate?.didPressStartStopButton()
  }

  func didPressRepeatButton() {
    delegate?.didPressRepeatButton()
  }

  func didPressNextButton() {
    delegate?.didPressNextButton()
  }

  func didPressPreviousButton() {
    delegate?.didPressPreviousButton()
  }

  func didPressProgressButton() {
    delegate?.didPressProgressButton()
  }

  func didPressConfigureButton() {
    delegate?.didPressConfigureButton()
  }
}
