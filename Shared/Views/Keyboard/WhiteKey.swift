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

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

final class WhiteKey: Control {
  // MARK: - Subviews

  private lazy var label: Label = {
    let label = Label()
    label.setUp()
    label.font = .headline
    label.textColor = .lightGray
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.numberOfLines = 0
    label.isUserInteractionEnabled = false

    return label
  }()

  private lazy var backgroundView: View = {
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
    view.backgroundStyle = .white
    view.cornerRadius = .cornerRadiusLg
    view.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var overlay: View = {
    let view = View()
    view.setUp()
    view.backgroundStyle = .clear
    view.cornerRadius = .cornerRadiusLg
    view.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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
    setUp()
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
      setAccessibilityLabel(text)
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

  // MARK: - Tracking

  override func beginTracking(_ touch: Touch, with event: UIEvent?) -> Bool {
    leadingAnchorConstraint.constant = .spacingXxs
    trailingAnchorConstraint.constant = -.spacingXxs
    return true
  }

  override func endTracking(_ touch: Touch?, with event: UIEvent?) {
    leadingAnchorConstraint.constant = .spacingXxxs
    trailingAnchorConstraint.constant = -.spacingXxxs
  }

  // MARK: - API

  func setTint(_ color: Color, percent: Double) {
    NSLayoutConstraint.deactivate([overlayheightAnchorConstraint])
    overlayheightAnchorConstraint = overlay.heightAnchor.constraint(
      equalTo: key.heightAnchor,
      multiplier: percent
    )
    NSLayoutConstraint.activate([overlayheightAnchorConstraint])

    overlay.backgroundStyle = color
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
    setUpAccessibility()
  }

  private func updateAppearance() {
    key.backgroundStyle = isEnabled ? .white : .white.withAlphaComponent(0.2)
    updateAccessibility()
  }

  private func setUpAccessibility() {
#if os(iOS)
    isAccessibilityElement = true
    accessibilityTraits = super.accessibilityTraits.union(.button)
    shouldGroupAccessibilityChildren = true
#endif
  }

  private func updateAccessibility() {
#if os(iOS)
    accessibilityTraits = isEnabled ? [.button] : [.button, .notEnabled]

    if isSelected {
      accessibilityTraits.insert(.selected)
    } else {
      accessibilityTraits.remove(.selected)
    }
#endif
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
      action: TipView.TipViewAction(title: tip.actionTitle) { [weak self] in
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

extension Control.Event {
#if os(iOS)
  static let tipDismissed: Control.Event = .applicationReserved
#endif

#if os(macOS)
  static let tipDismissed: Control.Event = .init(rawValue: 3)
#endif
}
