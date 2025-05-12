///
/// Colors.swift
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

import UIKit

extension UIColor {
  static func color(for progress: Double) -> UIColor {
    return if progress < 0.3 {
      .systemRed
    } else if progress < 0.5 {
      .systemOrange
    } else if progress < 0.8 {
      .amber
    } else if progress < 0.9 {
      .darkAmber
    } else {
      .systemGreen
    }
  }
}

// https://www.advancedswift.com/lighter-and-darker-uicolor-swift/
extension UIColor {
  func lighter(_ componentDelta: CGFloat = 0.1) -> UIColor {
    return makeColor(componentDelta: componentDelta)
  }

  func darker(_ componentDelta: CGFloat = 0.1) -> UIColor {
    return makeColor(componentDelta: -1 * componentDelta)
  }

  private func makeColor(componentDelta: CGFloat) -> UIColor {
    var red: CGFloat = 0
    var blue: CGFloat = 0
    var green: CGFloat = 0
    var alpha: CGFloat = 0

    getRed(
      &red,
      green: &green,
      blue: &blue,
      alpha: &alpha
    )

    return UIColor(
      red: add(componentDelta, toComponent: red),
      green: add(componentDelta, toComponent: green),
      blue: add(componentDelta, toComponent: blue),
      alpha: alpha
    )
  }

  private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
    return max(0, min(1, toComponent + value))
  }
}

// https://graphicdesign.stackexchange.com/a/77747
extension UIColor {
  func bestContrastingColor() -> UIColor {
    let (red, green, blue, _) = rgba

    if (0.2126 * red) + (0.7152 * green) + (0.0722 * blue) > 0.5 {
      return .dark
    }

    return .white
  }

  private var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    return (red: red, green: green, blue: blue, alpha: alpha)
  }
}
