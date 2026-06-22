///
/// Fonts.swift
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
typealias Font = NSFont
#endif

#if os(iOS)
import UIKit
typealias Font = UIFont
#endif

extension Font {
  static let largeTitle: Font = makeFont(textStyle: .largeTitle, size: 32, weight: .heavy)
  static let title1: Font = makeFont(textStyle: .title1, size: 28, weight: .bold)
  static let title2: Font = makeFont(textStyle: .title2, size: 22, weight: .bold)
  static let title3: Font = makeFont(textStyle: .title3, size: 20, weight: .bold)
  static let headline: Font = makeFont(textStyle: .headline, size: 17, weight: .medium)
  static let subheadline: Font = makeFont(textStyle: .subheadline, size: 16)
  static let body: Font = makeFont(textStyle: .body, size: 15)
  static let callout: Font = makeFont(textStyle: .callout, size: 14)
  static let footnote: Font = makeFont(textStyle: .footnote, size: 13)
  static let boldFootnote: Font = makeFont(textStyle: .footnote, size: 13, weight: .semibold)
  static let caption1: Font = makeFont(textStyle: .caption1, size: 12)
  static let caption2: Font = makeFont(textStyle: .caption2, size: 11)
  static let boldCaption2: Font = makeFont(textStyle: .caption2, size: 11, weight: .bold)
}

private func makeFont(
  textStyle: Font.TextStyle,
  size: CGFloat,
  weight: Font.Weight = .regular
) -> Font {
#if os(iOS)
  let font = Font.systemFont(ofSize: size, weight: weight)
  return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
#endif

#if os(macOS)
  Font.systemFont(ofSize: size, weight: weight)
#endif
}
