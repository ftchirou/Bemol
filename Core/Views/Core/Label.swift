///
/// Label.swift
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

final class Label: NSTextField {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    initialize()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initialize()
  }

  var numberOfLines: Int {
    get { maximumNumberOfLines }
    set { maximumNumberOfLines = newValue }
  }

  var text: String? {
    get { stringValue }
    set { stringValue = newValue ?? "" }
  }

  var textAlignment: NSTextAlignment {
    get { alignment }
    set { alignment = newValue }
  }

  var attributedText: NSAttributedString? {
    get { attributedStringValue }
    set { if let newValue { attributedStringValue = newValue } }
  }

  var adjustsFontForContentSizeCategory: Bool = false
  var adjustsFontSizeToFitWidth: Bool = false
  var maximumContentSizeCategory: Bool = false

  private func initialize() {
    isEditable = false
    isSelectable = false
    isBezeled = false
    backgroundColor = .clear
  }
}
#endif


#if os(iOS)
import UIKit
typealias Label = UILabel

extension Label {
  var fittingSize: CGSize {
    return systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
  }
}
#endif

