///
/// WhiteKey.swift
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

final class WhiteKey: UIControl {
  // MARK: - Subviews

  private lazy var label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .headline
    label.textColor = .lightGray
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.numberOfLines = 0
    label.isUserInteractionEnabled = false

    return label
  }()

  private lazy var backgroundView: UIView = {
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
    view.backgroundColor = .white
    view.layer.cornerRadius = .cornerRadiusLg
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var overlay: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.layer.cornerRadius = .cornerRadiusLg
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  // MARK: - Constraints

  private lazy var leadingAnchorConstraint = key.leadingAnchor
    .constraint(equalTo: backgroundView.leadingAnchor, constant: .spacingXxxs)

  private lazy var trailingAnchorConstraint = key.trailingAnchor
    .constraint(equalTo: backgroundView.trailingAnchor, constant: -.spacingXxxs)

  private lazy var overlayheightAnchorConstraint = overlay.heightAnchor
    .constraint(equalToConstant: 0)

  // MARK: - Properties

  private var tipView: TipView? = nil

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

  // MARK: - Tracking

  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    leadingAnchorConstraint.constant = .spacingXxs
    trailingAnchorConstraint.constant = -.spacingXxs
    return true
  }

  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    leadingAnchorConstraint.constant = .spacingXxxs
    trailingAnchorConstraint.constant = -.spacingXxxs
  }

  // MARK: - API

  func setTint(_ color: UIColor, percent: Double) {
    NSLayoutConstraint.deactivate([overlayheightAnchorConstraint])
    overlayheightAnchorConstraint = overlay.heightAnchor.constraint(
      equalTo: key.heightAnchor,
      multiplier: percent
    )
    NSLayoutConstraint.activate([overlayheightAnchorConstraint])
  
    overlay.backgroundColor = color
    overlay.isHidden = false

    if percent >= 0.1 {
      label.textColor = color.bestContrastingColor()
    }
  }

  func removeOverlay() {
    overlay.isHidden = true
    label.textColor = .lightGray
  }

  // MARK: - Private

  private func setUpAppearance() {
    isAccessibilityElement = true
    accessibilityTraits = super.accessibilityTraits.union(.button)
    shouldGroupAccessibilityChildren = true
  }

  private func updateAppearance() {
    key.backgroundColor = isEnabled ? .white : .dark.withAlphaComponent(0.8)
    accessibilityTraits = isEnabled ? [.button] : [.button, .notEnabled]

    if isSelected {
      accessibilityTraits.insert(.selected)
    } else {
      accessibilityTraits.remove(.selected)
    }
  }

  private func setUpViewHierarchy() {
    addSubview(backgroundView)
    addSubview(key)
    addSubview(overlay)
    addSubview(label)

    NSLayoutConstraint.activate([
      backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
      backgroundView.topAnchor.constraint(equalTo: topAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

      key.topAnchor.constraint(equalTo: backgroundView.topAnchor),
      key.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -.spacingXxs),
      leadingAnchorConstraint,
      trailingAnchorConstraint,

      label.bottomAnchor.constraint(equalTo: key.bottomAnchor, constant: -.spacingXs),
      label.centerXAnchor.constraint(equalTo: key.centerXAnchor),

      overlay.leadingAnchor.constraint(equalTo: key.leadingAnchor),
      overlay.bottomAnchor.constraint(equalTo: key.bottomAnchor),
      overlay.trailingAnchor.constraint(equalTo: key.trailingAnchor),
      overlayheightAnchorConstraint,
    ])
  }
}

// MARK: - TipHandler

extension WhiteKey: TipHandler {
  func handle(_ tip: Tip) {
    let tooltipView = TipPresenter.present(
      edge: .leftBottom,
      title: tip.title,
      message: tip.message,
      action: TipView.Action(title: tip.actionTitle) { [weak self] in
        self?.dismissTipView()
      },
      onView: self
    )

    tipView = tooltipView
  }

  private func dismissTipView() {
    if let tipView {
      TipPresenter.dismiss(tipView) { [weak self] in
        self?.tipView = nil
        self?.sendActions(for: .tipDismissed)
      }
    }
  }
}

extension UIControl.Event {
  static let tipDismissed = UIControl.Event(rawValue: 9847472)
}
