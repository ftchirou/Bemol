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
import UIKit

final class BlackKey: UIControl {
  // MARK: - Subviews

  private lazy var label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .boldCaption2
    label.textColor = .white
    label.textAlignment = .left
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.isUserInteractionEnabled = false
    label.transform = CGAffineTransform(rotationAngle: .pi * 3 / 2)

    return label
  }()

  private lazy var bevel: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .keyBed
    view.layer.cornerRadius = .cornerRadiusLg
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var key: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .dark
    view.layer.cornerRadius = .cornerRadiusLg
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false
  
    return view
  }()

  private lazy var interactionBlocker: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.isUserInteractionEnabled = true

    return view
  }()

  private lazy var keyOverlay: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.layer.cornerRadius = .cornerRadiusLg
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var bevelOverlay: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.layer.cornerRadius = .cornerRadiusLg
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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
      accessibilityLabel = text
    }
  }

  var tint: UIColor? {
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
    setUpViewHierarchy()
    setUpAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - API

  func setTint(_ color: UIColor, percent: Double) {
    NSLayoutConstraint.deactivate([keyOverlayHeightConstraint])
    keyOverlayHeightConstraint = keyOverlay.heightAnchor.constraint(
      equalTo: key.heightAnchor,
      multiplier: percent
    )
    NSLayoutConstraint.activate([keyOverlayHeightConstraint])

    keyOverlay.backgroundColor = color
    bevelOverlay.backgroundColor = color.darker(0.4)
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

  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    bottomAnchorConstraint.constant = -.spacingSm * bottomAnchorConstraintConstantMultiplier()
    return true
  }

  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    bottomAnchorConstraint.constant = -.spacingMd * bottomAnchorConstraintConstantMultiplier()
  }

  // MARK: - Private

  private func setUpAppearance() {
    isAccessibilityElement = true
    accessibilityTraits = super.accessibilityTraits.union([.button])
    shouldGroupAccessibilityChildren = true
  }

  private func updateAppearance() {
    if !isEnabled {
      installInteractionBlocker()
      key.backgroundColor = .clear
      bevel.backgroundColor = .disabledBackKey
      accessibilityTraits = [.button, .notEnabled]
    } else {
      removeInteractionBlocker()
      key.backgroundColor = .dark
      bevel.backgroundColor = .keyBed.darker(0.3)
      accessibilityTraits = [.button]
    }

    if isSelected {
      accessibilityTraits.insert(.selected)
    } else {
      accessibilityTraits.remove(.selected)
    }
  }

  private func installInteractionBlocker() {
    superview?.addSubview(interactionBlocker)

    NSLayoutConstraint.activate([
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
    
    NSLayoutConstraint.activate([
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
    switch (
      traitCollection.verticalSizeClass,
      traitCollection.horizontalSizeClass
    ) {
    case (.regular, .regular):
        .spacingXs + .spacingXxs + .spacingXxxs
    default:
        .spacingXs
    }

  }

  private func bottomAnchorConstraintConstantMultiplier() -> CGFloat {
    switch (
      traitCollection.verticalSizeClass,
      traitCollection.horizontalSizeClass
    ) {
    case (.regular, .regular):
      1.6
    default:
      1.0
    }
  }
}
