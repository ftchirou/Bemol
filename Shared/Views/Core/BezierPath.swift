///
/// BezierPath.swift
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
typealias BezierPath = NSBezierPath

extension BezierPath {
  convenience init(
      arcCenter center: CGPoint,
      radius: CGFloat,
      startAngle: CGFloat,
      endAngle: CGFloat,
      clockwise: Bool
  ) {
    self.init()
    let startAngle = Measurement(value: startAngle, unit: UnitAngle.radians)
      .converted(to: .degrees).value
    let endAngle = Measurement(value: endAngle, unit: UnitAngle.radians)
      .converted(to: .degrees).value

    appendArc(
      withCenter: center,
      radius: radius,
      startAngle: -startAngle,
      endAngle: -endAngle,
      clockwise: clockwise
    )
  }
}
#endif


#if os(iOS)
import UIKit
typealias BezierPath = UIBezierPath
#endif
