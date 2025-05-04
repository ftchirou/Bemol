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

@MainActor
final class ErrorScreen {
  // MARK: - Views
  
  private lazy var titleBar: TitleBar = {
    let bar = TitleBar()
    bar.translatesAutoresizingMaskIntoConstraints = false
    bar.isCancelButtonHidden = true
    bar.isDoneButtonHidden = true
    bar.title = "Something went wrong. Please try again later. Or maybe play a little with the piano"
    
    return bar
  }()
  
  private lazy var keyboardView: KeyboardView = {
    let keyboardView = KeyboardView(range: 1...2)
    keyboardView.translatesAutoresizingMaskIntoConstraints = false
    keyboardView.setEnabledForAllKeys(true)
    keyboardView.setTintForAllNotes(nil)
    keyboardView.isScrollEnabled = true
    keyboardView.delegate = KeyboardViewDelegate(
      didPressNote: { [weak self] in self?.didPressNote($0) },
      didReleaseNote: { [weak self] in self?.didReleaseNote($0) }
    )
    
    return keyboardView
  }()
  
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
  
  // MARK: - API
  
  var error: Error? {
    didSet {
      if let error {
        titleBar.title = AttributedString(error.localizedDescription)
      }
    }
  }
  
  // MARK: - Properties
  
  private let notePlayer: NotePlayer
  private let colors: [UIColor] = [
    .systemGreen, .systemTeal, .systemCyan, .systemBlue, .systemYellow, .systemPink, .systemPurple,
    .systemMint, .systemCyan, .systemBrown
  ]
  
  // MARK: - Initialization
  
  init(notePlayer: NotePlayer) {
    self.notePlayer = notePlayer
  }
}

// MARK: - KeyboardViewDelegate

extension ErrorScreen {
  func didPressNote(_ note: Note) {
    let random = (0..<colors.count).randomElement() ?? 0
    keyboardView.setTint(colors[random], for: [note])
    keyboardView.setLabel(note.name.letter, for: note)
    
    Task {
      try await notePlayer.playNote(note)
    }
  }
  
  func didReleaseNote(_ note: Note) {
    keyboardView.setTint(nil, for: [note])
    keyboardView.setLabel(nil, for: note)
  }
}
