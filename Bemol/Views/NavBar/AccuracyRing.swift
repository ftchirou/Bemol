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
import UIKit

final class AccuracyRing: UIControl {
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

  private lazy var rings: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.addSublayer(backgroundLayer)
    view.layer.addSublayer(foregroundLayer)
    view.transform = CGAffineTransform(rotationAngle: .pi * 3 / 2)
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .boldFootnote
    label.textColor = color
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.maximumContentSizeCategory = .accessibilityMedium
    label.isUserInteractionEnabled = false

    return label
  }()

  // MARK: - API

  var accuracy: Float = 0.0 {
    didSet {
      let formatter = NumberFormatter()
      formatter.numberStyle = .percent
      label.text = formatter.string(from: NSNumber(floatLiteral: Double(accuracy)))
      self.color = UIColor.color(for: Double(accuracy))
      setNeedsLayout()
    }
  }

  // MARK: - Properties

  private let strokeWidth: CGFloat = 6

  private var color: UIColor = .systemTeal {
    didSet { label.textColor = color }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpViewHierarchy()
    isAccessibilityElement = true
    accessibilityTraits = super.accessibilityTraits.union(.button)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Tracking

  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    return true
  }

  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    transform = CGAffineTransform(scaleX: 1, y: 1)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    let backgroundPath = UIBezierPath(
      arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
      radius: frame.width / 2,
      startAngle: 0,
      endAngle: .pi * 2,
      clockwise: true
    )

    let foregroundPath = UIBezierPath(
      arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
      radius: frame.width / 2,
      startAngle: 0,
      endAngle: CGFloat(accuracy) * (.pi * 2),
      clockwise: true
    )

    backgroundLayer.frame = bounds
    backgroundLayer.lineWidth = strokeWidth
    backgroundLayer.strokeColor = color.withAlphaComponent(0.5).cgColor
    backgroundLayer.path = backgroundPath.cgPath

    foregroundLayer.frame = bounds
    foregroundLayer.lineWidth = strokeWidth
    foregroundLayer.strokeColor = color.cgColor
    foregroundLayer.path = foregroundPath.cgPath
  }

  // MARK: - Private

  private func setUpViewHierarchy() {
    addSubview(rings)
    addSubview(label)

    NSLayoutConstraint.activate([
      rings.leadingAnchor.constraint(equalTo: leadingAnchor),
      rings.topAnchor.constraint(equalTo: topAnchor),
      rings.trailingAnchor.constraint(equalTo: trailingAnchor),
      rings.bottomAnchor.constraint(equalTo: bottomAnchor),

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
  }
}
