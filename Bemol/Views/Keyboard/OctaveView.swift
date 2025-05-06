///
/// OctaveView.swift
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

struct OctaveViewDelegate {
  let didPressNote: (NoteName, Octave) -> Void
  let didReleaseNote: (NoteName, Octave) -> Void
  let didDismissTip: () -> Void
}

@MainActor
final class OctaveView: UIView {
  // MARK: - Properties

  private let octave: Octave

  private lazy var naturalNotes: [NoteName: WhiteKey] = [
    .c: WhiteKey(frame: .minKeyFrame),
    .d: WhiteKey(frame: .minKeyFrame),
    .e: WhiteKey(frame: .minKeyFrame),
    .f: WhiteKey(frame: .minKeyFrame),
    .g: WhiteKey(frame: .minKeyFrame),
    .a: WhiteKey(frame: .minKeyFrame),
    .b: WhiteKey(frame: .minKeyFrame),
  ]

  private lazy var accidentalNotes: [NoteName: BlackKey] = [
    .dFlat: BlackKey(frame: .minKeyFrame),
    .eFlat: BlackKey(frame: .minKeyFrame),
    .gFlat: BlackKey(frame: .minKeyFrame),
    .aFlat: BlackKey(frame: .minKeyFrame),
    .bFlat: BlackKey(frame: .minKeyFrame),
  ]

  private var blackKeyWidth: CGFloat = 0
  private var whiteKeyWidth: CGFloat = 0

  // MARK: - API

  var delegate: OctaveViewDelegate?

  // MARK: - Initialization

  init(octave: Octave) {
    self.octave = octave
    super.init(frame: .zero)
    setUpViewHierarchy()
    setUpAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - API

  func setEnabled(_ enabled: Bool, for note: NoteName) {
    naturalNotes[note]?.isEnabled = enabled
    accidentalNotes[note]?.isEnabled = enabled
  }

  func setSelected(_ selected: Bool, for note: NoteName) {
    naturalNotes[note]?.isSelected = selected
    accidentalNotes[note]?.isSelected = selected
  }

  func setTint(_ tint: UIColor?, for note: NoteName) {
    naturalNotes[note]?.tint = tint
    accidentalNotes[note]?.tint = tint
  }

  func setLabel(_ label: String?, for note: NoteName) {
    naturalNotes[note]?.text = label
    accidentalNotes[note]?.text = label
  }

  func setTint(_ color: UIColor, percent: Double, for note: NoteName) {
    naturalNotes[note]?.setTint(color, percent: percent)
    accidentalNotes[note]?.setTint(color, percent: percent)
  }

  func view(for note: NoteName) -> UIView? {
    naturalNotes[note] ?? accidentalNotes[note]
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let whiteKeyWidth = self.bounds.width / CGFloat(naturalNotes.count)
    let blackKeyWidth = whiteKeyWidth / 2
    let blackKeyHeight = bounds.height / 1.5

    let notes = naturalNotes.keys.sorted()

    for (i, note) in notes.enumerated() {
      let key = naturalNotes[note]!
      key.frame = CGRect(
        x: CGFloat(i) * whiteKeyWidth,
        y: 0,
        width: whiteKeyWidth,
        height: bounds.height
      )
    }

    accidentalNotes[.dFlat]?.frame = CGRect(
      x: naturalNotes[.c]!.frame.maxX - (whiteKeyWidth / 3),
      y: 0,
      width: blackKeyWidth,
      height: blackKeyHeight
    )

    accidentalNotes[.eFlat]?.frame = CGRect(
      x: naturalNotes[.d]!.frame.maxX - (whiteKeyWidth / 5),
      y: 0,
      width: blackKeyWidth,
      height: blackKeyHeight
    )

    accidentalNotes[.gFlat]?.frame = CGRect(
      x: naturalNotes[.f]!.frame.maxX - (whiteKeyWidth / 3),
      y: 0,
      width: blackKeyWidth,
      height: blackKeyHeight
    )

    accidentalNotes[.aFlat]?.frame = CGRect(
      x: naturalNotes[.g]!.frame.maxX - (blackKeyWidth / 2),
      y: 0,
      width: blackKeyWidth,
      height: blackKeyHeight
    )

    accidentalNotes[.bFlat]?.frame = CGRect(
      x: naturalNotes[.a]!.frame.maxX - (whiteKeyWidth / 5),
      y: 0,
      width: blackKeyWidth,
      height: blackKeyHeight
    )
  }

  private func setUpViewHierarchy() {
    for (note, key) in naturalNotes {
      addSubview(key)
      setUpActions(for: note, key: key)
    }

    for (note, key) in accidentalNotes {
      addSubview(key)
      setUpActions(for: note, key: key)
    }
  }

  private func setUpActions(for note: NoteName, key: UIControl) {
    key.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        self.delegate?.didPressNote(note, self.octave)
      },
      for: .touchDown
    )

    key.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        self.delegate?.didReleaseNote(note, self.octave)
      },
      for: .touchUpInside
    )

    key.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        self.delegate?.didDismissTip()
      },
      for: .tipDismissed
    )
  }

  private func setUpAppearance() {
    clipsToBounds = true
  }
}

// MARK: - TipHandler

extension OctaveView: TipHandler {
  func handle(_ tip: Tip) {
    guard
      let view = naturalNotes.sorted(by: { $0.key < $1.key })
        .filter({ $0.1.isEnabled })
        .last?.value
    else { return }

    view.handle(tip)
  }
}

private extension CGRect {
  // Minimum rect that will satisfy the constraints in a key.
  static let minKeyFrame = CGRect(x: 0, y: 0, width: 48, height: 48)
}
