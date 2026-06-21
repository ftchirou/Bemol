///
/// BlackKey.swift
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

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

final class BlackKey: Control {
  // MARK: - Subviews

  private lazy var label: Label = {
    let label = Label()
    label.setUp()
    label.font = .boldCaption2
    label.textColor = .white
    label.textAlignment = .left
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.isUserInteractionEnabled = false
    label.transform = CGAffineTransform(rotationAngle: .pi * 3 / 2)

    return label
  }()

  private lazy var bevel: View = {
    let view = View()
    view.setUp()
    view.backgroundStyle = .keyBed
    view.cornerRadius = .cornerRadiusLg
    view.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var key: View = {
    let view = View()
    view.setUp()
    view.backgroundStyle = .dark
    view.cornerRadius = .cornerRadiusLg
    view.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var interactionBlocker: View = {
    let view = View()
    view.setUp()
    view.backgroundStyle = .clear
    view.isUserInteractionEnabled = true

    return view
  }()

  private lazy var keyOverlay: View = {
    let view = View()
    view.setUp()
    view.backgroundStyle = .clear
    view.cornerRadius = .cornerRadiusLg
    view.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var bevelOverlay: View = {
    let view = View()
    view.setUp()
    view.backgroundStyle = .clear
    view.cornerRadius = .cornerRadiusLg
    view.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  // MARK: - Constraints

  private lazy var bottomAnchorConstraint = key.bottomAnchor
    .constraint(
      equalTo: bevel.bottomAnchor,
      constant: -.spacingMd * bottomAnchorConstraintConstantMultiplier()
    )

  private lazy var keyOverlayHeightConstraint = keyOverlay.heightAnchor
    .constraint(equalToConstant: 0)

  // MARK: - API

  var text: String? {
    didSet {
      label.text = text
    }
  }

  var tint: Color? {
    didSet {
      guard let color = tint else {
        removeOverlay()
        return
      }

      setTint(color, percent: 1.0)
    }
  }

  override var isEnabled: Bool {
    didSet {
      updateAppearance()
    }
  }

  override var isSelected: Bool {
    didSet {
      updateAppearance()
    }
  }

  // MARK: - Initialization

  override public init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
    setUpViewHierarchy()
    setUpAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - API

  func setTint(_ color: Color, percent: Double) {
    LayoutConstraint.deactivate([keyOverlayHeightConstraint])
    keyOverlayHeightConstraint = keyOverlay.heightAnchor.constraint(
      equalTo: key.heightAnchor,
      multiplier: percent
    )
    LayoutConstraint.activate([keyOverlayHeightConstraint])

    keyOverlay.backgroundStyle = color
    bevelOverlay.backgroundStyle = color.darker(0.4)
    keyOverlay.isHidden = false
    bevelOverlay.isHidden = percent <= 0

    if percent >= 0.1 {
      label.textColor = color.bestContrastingColor()
    }
  }

  func removeOverlay() {
    keyOverlay.isHidden = true
    bevelOverlay.isHidden = true
    label.textColor = .white
  }

  // MARK: - Tracking

  override func beginTracking(_ touch: Touch, with event: UIEvent?) -> Bool {
    bottomAnchorConstraint.constant = -.spacingSm * bottomAnchorConstraintConstantMultiplier()
    return true
  }

  override func endTracking(_ touch: Touch?, with event: UIEvent?) {
    bottomAnchorConstraint.constant = -.spacingMd * bottomAnchorConstraintConstantMultiplier()
  }

  // MARK: - Private

  private func setUpAppearance() {
    setUpAccessibility()
  }

  private func updateAppearance() {
    if !isEnabled {
      installInteractionBlocker()
      key.backgroundStyle = .clear
      bevel.backgroundStyle = .disabledBackKey
    } else {
      removeInteractionBlocker()
      key.backgroundStyle = .dark
      bevel.backgroundStyle = .keyBed.darker(0.3)
    }

    updateAccessibility()
  }

  private func setUpAccessibility() {
#if os(iOS)
    isAccessibilityElement = true
    accessibilityTraits = super.accessibilityTraits.union([.button])
    shouldGroupAccessibilityChildren = true
#endif
  }

  private func updateAccessibility() {
#if os(iOS)
    if !isEnabled {
      accessibilityTraits = [.button, .notEnabled]
    } else {
      accessibilityTraits = [.button]
    }

    if isSelected {
      accessibilityTraits.insert(.selected)
    } else {
      accessibilityTraits.remove(.selected)
    }
#endif
  }

  private func installInteractionBlocker() {
    superview?.addSubview(interactionBlocker)

    LayoutConstraint.activate([
      interactionBlocker.leadingAnchor.constraint(equalTo: leadingAnchor),
      interactionBlocker.topAnchor.constraint(equalTo: topAnchor),
      interactionBlocker.trailingAnchor.constraint(equalTo: trailingAnchor),
      interactionBlocker.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func removeInteractionBlocker() {
    if interactionBlocker.superview != nil {
      interactionBlocker.removeConstraints(interactionBlocker.constraints)
      interactionBlocker.removeFromSuperview()
    }
  }

  private func setUpViewHierarchy() {
    addSubview(interactionBlocker)
    addSubview(bevel)
    addSubview(key)
    addSubview(bevelOverlay)
    addSubview(keyOverlay)
    addSubview(label)

    LayoutConstraint.activate([
      bevel.leadingAnchor.constraint(equalTo: leadingAnchor),
      bevel.topAnchor.constraint(equalTo: topAnchor),
      bevel.trailingAnchor.constraint(equalTo: trailingAnchor),
      bevel.bottomAnchor.constraint(equalTo: bottomAnchor),

      key.leadingAnchor.constraint(
        equalTo: bevel.leadingAnchor,
        constant: keyLeadingTrailingConstraintsConstant()
      ),
      key.topAnchor.constraint(equalTo: bevel.topAnchor),
      key.trailingAnchor.constraint(
        equalTo: bevel.trailingAnchor,
        constant: -keyLeadingTrailingConstraintsConstant()
      ),
      bottomAnchorConstraint,

      label.bottomAnchor.constraint(equalTo: key.bottomAnchor, constant: -.spacingLg),
      label.centerXAnchor.constraint(equalTo: key.centerXAnchor),

      keyOverlay.leadingAnchor.constraint(equalTo: key.leadingAnchor),
      keyOverlay.bottomAnchor.constraint(equalTo: key.bottomAnchor),
      keyOverlay.trailingAnchor.constraint(equalTo: key.trailingAnchor),
      keyOverlayHeightConstraint,

      bevelOverlay.leadingAnchor.constraint(equalTo: bevel.leadingAnchor),
      bevelOverlay.bottomAnchor.constraint(equalTo: bevel.bottomAnchor),
      bevelOverlay.trailingAnchor.constraint(equalTo: bevel.trailingAnchor),
      bevelOverlay.topAnchor.constraint(equalTo: keyOverlay.topAnchor),
    ])
  }

  private func keyLeadingTrailingConstraintsConstant() -> CGFloat {
#if os(macOS)
    return .spacingXs
#endif

#if os(iOS)
    switch (
      traitCollection.verticalSizeClass,
      traitCollection.horizontalSizeClass
    ) {
    case (.regular, .regular):
      .spacingXs + .spacingXxs + .spacingXxxs
    default:
      .spacingXs
    }
#endif
  }

  private func bottomAnchorConstraintConstantMultiplier() -> CGFloat {
#if os(macOS)
    return 1.0
#endif

#if os(iOS)
    switch (
      traitCollection.verticalSizeClass,
      traitCollection.horizontalSizeClass
    ) {
    case (.regular, .regular):
      1.6
    default:
      1.0
    }
#endif
  }
}
