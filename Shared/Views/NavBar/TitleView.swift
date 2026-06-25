///
/// TitleView.swift
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

final class TitleView: View {
  // MARK: - Subviews

  private lazy var background: View = {
    let view = View()
    view.setUp()
    view.backgroundStyle = .dark
    view.cornerRadius = .cornerRadiusSm

    return view
  }()

  private lazy var label: Label = {
    let label = Label()
    label.setUp()
    label.font = .boldFootnote
    label.textAlignment = .center
    label.textColor = .buttonForeground
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true
    label.setContentHuggingPriority(.required, for: .horizontal)
    label.setContentCompressionResistancePriority(.required, for: .horizontal)

    return label
  }()

  // MARK: - Sizing

  override var intrinsicContentSize: CGSize {
    CGSize(
      width: .spacingXs + .spacingSm + label.intrinsicContentSize.width + .spacingSm + .spacingXs,
      height: .spacingXs + label.intrinsicContentSize.height + .spacingXs
    )
  }

  // MARK: - API

  var title: AttributedString? {
    didSet {
      label.attributedText = title.flatMap { NSAttributedString($0) }
      setAccessibilityLabel(title?.description)
    }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: .zero)
    setUpViewHierarchy()
    setUpAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Private

  private func setUpAppearance() {
#if os(iOS)
    accessibilityTraits = .staticText
#endif
  }

  private func setUpViewHierarchy() {
    addSubview(background)
    background.addSubview(label)

    NSLayoutConstraint.activate([
      background.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingXs),
      background.topAnchor.constraint(equalTo: topAnchor),
      background.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingXs),
      background.bottomAnchor.constraint(equalTo: bottomAnchor),

      label.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: .spacingSm),
      label.centerXAnchor.constraint(equalTo: background.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: background.centerYAnchor),
      label.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -.spacingSm),
      label.topAnchor.constraint(lessThanOrEqualTo: background.topAnchor, constant: .spacingXxs),
      label.bottomAnchor.constraint(
        greaterThanOrEqualTo: background.bottomAnchor, constant: -.spacingXxs),
    ])
  }
}
