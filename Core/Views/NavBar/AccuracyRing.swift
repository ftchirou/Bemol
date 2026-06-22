///
/// AccuracyRing.swift
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

final class AccuracyRing: Control {
  // MARK: - Layers

  private lazy var backgroundLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.strokeColor = color.withAlphaComponent(0.5).cgColor
    layer.lineCap = .round
    layer.lineWidth = strokeWidth

    return layer
  }()

  private lazy var foregroundLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.strokeColor = color.cgColor
    layer.lineCap = .round
    layer.lineWidth = strokeWidth

    return layer
  }()

  // MARK: - Subviews

  private lazy var rings: View = {
    let view = View()
    view.setUp()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSublayer(backgroundLayer)
    view.addSublayer(foregroundLayer)
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var label: Label = {
    let label = Label()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .boldFootnote
    label.textColor = color
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.isUserInteractionEnabled = false

#if os(iOS)
    label.maximumContentSizeCategory = .accessibilityMedium
#endif

    return label
  }()

  // MARK: - API

  var accuracy: Float = 0.0 {
    didSet {
      let formatter = NumberFormatter()
      formatter.numberStyle = .percent
      label.text = formatter.string(from: NSNumber(floatLiteral: Double(accuracy)))
      self.color = Color.color(for: Double(accuracy))
      setNeedsLayout()
    }
  }

  var strokeWidth: CGFloat = 6 {
    didSet {
      setNeedsLayout()
    }
  }

  // MARK: - Properties

  private var color: Color = .systemTeal {
    didSet { label.textColor = color }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpViewHierarchy()

#if os(iOS)
    isAccessibilityElement = true
    accessibilityTraits = super.accessibilityTraits.union(.button)
#endif
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Tracking

  override func beginTracking(_ touch: Touch, with event: UIEvent?) -> Bool {
    transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    return true
  }

  override func endTracking(_ touch: Touch?, with event: UIEvent?) {
    transform = CGAffineTransform(scaleX: 1, y: 1)
  }

  // MARK: - Layout

#if os(iOS)
  override func layoutSubviews() {
    super.layoutSubviews()
    performLayout()
  }
#endif

#if os(macOS)
  override func layout() {
    super.layout()
    performLayout()
  }
#endif

  private func performLayout() {
    let backgroundPath = BezierPath(
      arcCenter: CGPoint(x: rings.frame.width / 2, y: rings.frame.height / 2),
      radius: rings.frame.width / 2,
      startAngle: 0,
      endAngle: .pi * 2,
      clockwise: true
    )

    let foregroundPath = BezierPath(
      arcCenter: CGPoint(x: rings.frame.width / 2, y: rings.frame.height / 2),
      radius: rings.frame.width / 2,
      startAngle: 0,
      endAngle: CGFloat(accuracy) * (.pi * 2),
      clockwise: true
    )

    backgroundLayer.frame = rings.bounds
    backgroundLayer.lineWidth = strokeWidth
    backgroundLayer.strokeColor = color.withAlphaComponent(0.5).cgColor
    backgroundLayer.path = backgroundPath.cgPath
    backgroundLayer.fillColor = Color.clear.cgColor

    foregroundLayer.frame = rings.bounds
    foregroundLayer.lineWidth = strokeWidth
    foregroundLayer.strokeColor = color.cgColor
    foregroundLayer.path = foregroundPath.cgPath
    foregroundLayer.fillColor = Color.clear.cgColor

    rings.rotate(by: .pi * 3 / 2)
  }

  // MARK: - Private

  private func setUpViewHierarchy() {
    addSubview(rings)
    addSubview(label)

    LayoutConstraint.activate([
      rings.leadingAnchor.constraint(equalTo: leadingAnchor),
      rings.topAnchor.constraint(equalTo: topAnchor),
      rings.widthAnchor.constraint(equalTo: heightAnchor),
      rings.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

#if os(iOS)
    LayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      label.leadingAnchor.constraint(
        greaterThanOrEqualTo: leadingAnchor, constant: (strokeWidth + 2)),
      label.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: (strokeWidth + 2)),
      label.trailingAnchor.constraint(
        lessThanOrEqualTo: trailingAnchor, constant: -(strokeWidth + 2)),
      label.bottomAnchor.constraint(
        greaterThanOrEqualTo: bottomAnchor, constant: -(strokeWidth + 2)),
    ])
#endif

#if os(macOS)
    LayoutConstraint.activate([
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      label.leadingAnchor.constraint(equalTo: rings.trailingAnchor, constant: .spacingXs),
      label.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: (strokeWidth + 2)),
      label.bottomAnchor.constraint(
        greaterThanOrEqualTo: bottomAnchor, constant: -(strokeWidth + 2)),
    ])
#endif
  }
}
