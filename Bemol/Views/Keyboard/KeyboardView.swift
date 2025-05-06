///
/// KeyboardView.swift
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

struct KeyboardViewDelegate {
  let didPressNote: (Note) -> Void
  let didReleaseNote: (Note) -> Void
  let didDismissTip: () -> Void

  init(
    didPressNote: @escaping (Note) -> Void,
    didReleaseNote: @escaping (Note) -> Void,
    didDismissTip: @escaping () -> Void = {}
  ) {
    self.didPressNote = didPressNote
    self.didReleaseNote = didReleaseNote
    self.didDismissTip = didDismissTip
  }
}

@MainActor
final class KeyboardView: UIView {
  // MARK: - Subviews

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.panGestureRecognizer.cancelsTouchesInView = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.isScrollEnabled = true
    scrollView.bounces = true

    return scrollView
  }()

  private lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private var octaveViews: [OctaveView] = []
  private var octaves: [[UIView]] = []

  // MARK: - API

  var delegate: KeyboardViewDelegate?

  var isScrollEnabled: Bool {
    get { scrollView.isScrollEnabled }
    set { scrollView.isScrollEnabled = newValue }
  }
  
  // MARK: - Properties

  private let range: ClosedRange<Octave>

  init(range: ClosedRange<Octave>) {
    self.range = range
    super.init(frame: .zero)
    setUpViewHierarchy()
    setUpOctaveViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - API

  func scrollTo(note: Note, animated: Bool = true) {
    if let view = octaveViews[Int(note.octave - range.lowerBound)].view(for: note.name) {
      scrollView.setContentOffset(CGPoint(x: view.frame.minX, y: 0), animated: animated)
    }
  }

  func setEnabled(_ enabled: Bool, for notes: [Note]) {
    for note in notes {
      setEnabled(enabled, for: note)
    }
  }

  func setLabels(_ labels: [String], for notes: [Note]) {
    guard labels.count == notes.count else { return }

    for (i, note) in notes.enumerated() {
      setLabel(labels[i], for: note)
    }
  }

  func setLabelForAllNotes(_ label: String?) {
    for i in 0..<octaveViews.count {
      for note in NoteName.all {
        octaveViews[i].setLabel(label, for: note)
      }
    }
  }

  func setTints(_ colors: [UIColor?], for notes: [Note]) {
    guard colors.count == notes.count else { return }

    for (i, note) in notes.enumerated() {
      setTint(colors[i], for: note)
    }
  }

  func setTint(_ color: UIColor?, for notes: [Note]) {
    for note in notes {
      setTint(color, for: note)
    }
  }

  func setTintForAllNotes(_ color: UIColor?) {
    for i in 0..<octaveViews.count {
      for note in NoteName.all {
        octaveViews[i].setTint(color, for: note)
      }
    }
  }

  func setEnabled(_ enabled: Bool, for note: Note) {
    octaveViews[Int(note.octave - range.lowerBound)].setEnabled(enabled, for: note.name)
  }

  func setSelected(_ selected: Bool, for note: Note) {
    octaveViews[Int(note.octave - range.lowerBound)].setSelected(selected, for: note.name)
  }

  func setEnabledForAllKeys(_ enabled: Bool) {
    for i in 0..<octaveViews.count {
      for note in NoteName.all {
        octaveViews[i].setEnabled(enabled, for: note)
      }
    }
  }

  func setTint(_ tint: UIColor?, for note: Note) {
    octaveViews[Int(note.octave - range.lowerBound)].setTint(tint, for: note.name)
  }

  func setLabel(_ label: String?, for note: Note) {
    octaveViews[Int(note.octave - range.lowerBound)].setLabel(label, for: note.name)
  }

  func setTint(_ color: UIColor, percent: Double, for note: Note) {
    octaveViews[Int(note.octave - range.lowerBound)].setTint(
      color,
      percent: percent,
      for: note.name
    )
  }

  // MARK: - Private

  private func setUpViewHierarchy() {
    addSubview(scrollView)
    scrollView.addSubview(contentView)

    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      contentView.heightAnchor.constraint(equalTo: heightAnchor),

      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func setUpOctaveViews() {
    for octave in range {
      let view = OctaveView(octave: octave)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.delegate = OctaveViewDelegate(
        didPressNote: { [weak self] note, octave in self?.didPressNote(note, octave: octave) },
        didReleaseNote: { [weak self] note, octave in self?.didReleaseNote(note, octave: octave) },
        didDismissTip: { [weak self] in self?.didDismissTip() }
      )
      contentView.addSubview(view)

      view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
      view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
      view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.88).isActive = true
      view.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true

      octaveViews.append(view)
    }

    octaveViews[0].leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true

    for octave in 1..<range.count {
      octaveViews[octave].leadingAnchor
        .constraint(equalTo: octaveViews[octave - 1].trailingAnchor).isActive = true
    }

    contentView.widthAnchor
      .constraint(
        equalTo: octaveViews[0].widthAnchor,
        multiplier: CGFloat(octaveViews.count)
      ).isActive = true
  }
}

// MARK: - OctaveViewDelegate

extension KeyboardView {
  func didPressNote(_ note: NoteName, octave: Octave) {
    delegate?.didPressNote(Note(name: note, octave: octave))
  }

  func didReleaseNote(_ note: NoteName, octave: Octave) {
    delegate?.didReleaseNote(Note(name: note, octave: octave))
  }

  func didDismissTip() {
    delegate?.didDismissTip()
  }
}

// MARK: - TipHandler

extension KeyboardView: TipHandler {
  func handle(_ tip: Tip) {
    octaveViews.first?.handle(tip)
  }

  func dismissTip() {
  }
}
