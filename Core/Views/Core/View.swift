///
/// View.swift
/// Bemol
///
/// Copyright 2026 Faiçal Tchirou
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


#if os(macOS)
import AppKit

typealias View = NSView

extension View {
  var alpha: CGFloat {
    get { alphaValue }
    set { alphaValue = newValue }
  }

  var backgroundStyle: Color? {
    get { layer?.backgroundColor.flatMap { Color(cgColor: $0) } }
    set { layer?.backgroundColor = newValue?.cgColor }
  }

  var cornerRadius: CGFloat {
    get { layer?.cornerRadius ?? 0 }
    set { layer?.cornerRadius = newValue }
  }

  var maskedCorners: CACornerMask {
    get { layer?.maskedCorners ?? [] }
    set {
      var newMaskedCorners: CACornerMask = []

      if newValue.contains(.layerMinXMaxYCorner) {
        newMaskedCorners.insert(.layerMinXMinYCorner)
      }

      if newValue.contains(.layerMaxXMaxYCorner) {
        newMaskedCorners.insert(.layerMaxXMinYCorner)
      }

      layer?.maskedCorners = newMaskedCorners
    }
  }

  var transform: CGAffineTransform {
    get { (layer?.transform).flatMap { CATransform3DGetAffineTransform($0) } ?? .identity }
    set { layer?.transform = CATransform3DMakeAffineTransform(newValue) }
  }

  var shadowColor: CGColor {
    get { layer?.shadowColor ?? .clear }
    set { layer?.shadowColor = newValue }
  }

  var shadowRadius: CGFloat {
    get { layer?.shadowRadius ?? 0 }
    set { layer?.shadowRadius = newValue }
  }

  var shadowOffset: CGSize {
    get { layer?.shadowOffset ?? .zero }
    set { layer?.shadowOffset = newValue }
  }

  var shadowOpacity: Float {
    get { layer?.shadowOpacity ?? 0 }
    set { layer?.shadowOpacity = newValue }
  }

  var masksToBounds: Bool {
    get { layer?.masksToBounds ?? false }
    set { layer?.masksToBounds = newValue }
  }

  var isUserInteractionEnabled: Bool {
    // TODO
    get { true }
    set {}
  }

  func layoutIfNeeded() {
    layoutSubtreeIfNeeded()
  }

  func setUp() {
    wantsLayer = true
    translatesAutoresizingMaskIntoConstraints = false
  }

  func rotate(by angleRadians: CGFloat) {
    let rotation = CGAffineTransform(rotationAngle: -angleRadians)
    let translation = CGAffineTransform(
      translationX: (bounds.height / 2) + (bounds.width / 2),
      y: 0
    )

    // We're rotating about (0, 0) on macOS, so we need to translate
    // after the rotation to obtain the same effect as on iOS.
    let transform = rotation.concatenating(translation)
    layer?.transform = CATransform3DMakeAffineTransform(transform)
  }

  func bringSubviewToFront(_ view: View) {
  }

  func addSublayer(_ layer: CALayer) {
    self.layer?.addSublayer(layer)
  }

  func setNeedsLayout() {
    needsLayout = true
  }
}
#endif


#if os(iOS)
import UIKit

typealias View = UIView

extension View {
  var backgroundStyle: UIColor? {
    get { backgroundColor }
    set { backgroundColor = newValue }
  }

  var cornerRadius: CGFloat {
    get { layer.cornerRadius }
    set { layer.cornerRadius = newValue }
  }

  var maskedCorners: CACornerMask {
    get { layer.maskedCorners }
    set { layer.maskedCorners = newValue }
  }

  var shadowColor: CGColor {
    get { layer.shadowColor ?? UIColor.clear.cgColor }
    set { layer.shadowColor = newValue }
  }

  var shadowRadius: CGFloat {
    get { layer.shadowRadius }
    set { layer.shadowRadius = newValue }
  }

  var shadowOffset: CGSize {
    get { layer.shadowOffset }
    set { layer.shadowOffset = newValue }
  }

  var shadowOpacity: Float {
    get { layer.shadowOpacity }
    set { layer.shadowOpacity = newValue }
  }

  var masksToBounds: Bool {
    get { layer.masksToBounds }
    set { layer.masksToBounds = newValue }
  }

  func setUp() {
    translatesAutoresizingMaskIntoConstraints = false
  }

  func addSublayer(_ layer: CALayer) {
    self.layer.addSublayer(layer)
  }

  func rotate(by angleRadians: CGFloat) {
    transform = CGAffineTransform(rotationAngle: angleRadians)
  }

  func setAccessibilityLabel(_ accessibilityLabel: String?) {
    self.accessibilityLabel = accessibilityLabel
  }
}
#endif
