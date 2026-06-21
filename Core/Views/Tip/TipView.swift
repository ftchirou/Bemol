///
/// TipView.swift
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

final class TipView: View {
  enum Edge {
    case topLeft
    case topCenter
    case topRight
    case leftBottom
  }

  struct TipViewAction {
    let title: String
    let perform: () -> Void
  }

  // MARK: - Subviews

  private lazy var caret: View = {
    let view = View()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundStyle = .tooltip
    view.widthAnchor.constraint(equalToConstant: .caretSize).isActive = true
    view.heightAnchor.constraint(equalToConstant: .caretSize).isActive = true
    view.cornerRadius = .cornerRadiusSm
    view.transform = CGAffineTransform(rotationAngle: .pi / 4)
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var titleLabel: Label = {
    let label = Label()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .boldFootnote
    label.text = title
    label.textColor = .tooltipText
    label.textAlignment = .left
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    label.adjustsFontForContentSizeCategory = true
    label.isUserInteractionEnabled = false

#if os(iOS)
    label.maximumContentSizeCategory = .extraLarge
#endif

    return label
  }()

  private lazy var messageLabel: Label = {
    let label = Label()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .footnote
    label.text = message
    label.textColor = .tooltipText
    label.textAlignment = .left
    label.numberOfLines = 0
    label.adjustsFontSizeToFitWidth = true
    label.adjustsFontForContentSizeCategory = true
    label.isUserInteractionEnabled = false
    label.widthAnchor.constraint(greaterThanOrEqualToConstant: .labelMinWidth).isActive = true

#if os(iOS)
    label.maximumContentSizeCategory = .extraLarge
#endif


    return label
  }()

  private lazy var button: Button = {
    let button = Button(
      type: .plain,
      title: action.title,
      size: .small,
      foregroundColor: .systemOrange
    )
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addAction(
      Action { [weak self] _ in
        self?.action.perform()
      },
      for: .touchUpInside
    )
    button.isUserInteractionEnabled = true

    return button
  }()

  private lazy var bubble: View = {
    let view = View()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundStyle = .tooltip
    view.cornerRadius = .cornerRadiusMd
    view.isUserInteractionEnabled = false
    view.shadowColor = Color.black.cgColor
    view.shadowRadius = 10
    view.shadowOffset = CGSize(width: 0, height: 3)
    view.shadowOpacity = 0.15
    view.masksToBounds = false
    return view
  }()

  // MARK: - Constraints

  private lazy var labelMaxWidthConstraint = messageLabel
    .widthAnchor
    .constraint(lessThanOrEqualToConstant: .labelMaxWidth)

  // MARK: - Sizing

  var maxWidth: CGFloat = .tipViewDefaultMaxWidth {
    didSet {
      labelMaxWidthConstraint.constant = max(
        min(maxWidth, .tipViewDefaultMaxWidth) - (.labelHorizontalMargin * 2),
        .labelMinWidth
      )
      layoutIfNeeded()
    }
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(
      width: messageLabel.fittingSize.width + .labelHorizontalMargin * 2,
      height: (.caretSize / 2)
        + (messageLabel.intrinsicContentSize.height + .labelVerticalMargin * 2)
        + .caretSize / 4
    )
  }

  // MARK: - Properties

  let edge: Edge
  let title: String
  let message: String
  let action: TipViewAction

  // MARK: - Initialization

  init(edge: Edge, title: String, message: String, action: TipViewAction) {
    self.edge = edge
    self.title = title
    self.message = message
    self.action = action
    super.init(frame: .zero)
    setUpViewHierarchy()
    setUpAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Hit Testing

  #if os(iOS)
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> View? {
    if button.frame.contains(point) {
      return button
    }

    return super.hitTest(point, with: event)
  }
#endif

#if os(macOS)
  override func hitTest(_ point: NSPoint) -> NSView? {
    if button.frame.contains(point) {
      return button
    }

    return super.hitTest(point)
  }
#endif

  // MARK: - Private Helpers

  private func setUpAppearance() {
    setUpAccessibility()
  }

  private func setUpViewHierarchy() {
    addSubview(bubble)
    addSubview(caret)
    addSubview(titleLabel)
    addSubview(messageLabel)
    addSubview(button)

    LayoutConstraint.activate([
      bubble.leadingAnchor.constraint(
        equalTo: messageLabel.leadingAnchor, constant: -.labelHorizontalMargin),
      bubble.trailingAnchor.constraint(
        equalTo: messageLabel.trailingAnchor, constant: .labelHorizontalMargin),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingSm),
      messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -.spacingSm),
      labelMaxWidthConstraint,
    ])

    switch edge {
    case .topLeft:
      caret.maskedCorners = [.layerMinXMinYCorner]
      LayoutConstraint.activate([
        caret.topAnchor.constraint(equalTo: topAnchor, constant: .caretSize / 4),
        caret.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: .spacingSm),
        bubble.topAnchor.constraint(equalTo: caret.bottomAnchor, constant: -.caretSize / 2),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .labelVerticalMargin),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    case .topCenter:
      caret.maskedCorners = [.layerMinXMinYCorner]
      LayoutConstraint.activate([
        caret.topAnchor.constraint(equalTo: topAnchor, constant: .caretSize / 4),
        caret.centerXAnchor.constraint(equalTo: centerXAnchor),
        bubble.topAnchor.constraint(equalTo: caret.bottomAnchor, constant: -.caretSize / 2),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .labelVerticalMargin),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    case .topRight:
      caret.maskedCorners = [.layerMinXMinYCorner]
      LayoutConstraint.activate([
        caret.topAnchor.constraint(equalTo: topAnchor, constant: .caretSize / 4),
        caret.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -.spacingSm),
        bubble.topAnchor.constraint(equalTo: caret.bottomAnchor, constant: -.caretSize / 2),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .labelVerticalMargin),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    case .leftBottom:
      caret.maskedCorners = [.layerMinXMaxYCorner]
      LayoutConstraint.activate([
        caret.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -.caretSize / 2),
        caret.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -.spacingSm),
        bubble.topAnchor.constraint(equalTo: topAnchor),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .spacingSm),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    }
  }

  private func setUpAccessibility() {
#if os(iOS)
    accessibilityViewIsModal = true
#endif
  }
}

// MARK: - Reusable constants

@MainActor
extension CGFloat {
  fileprivate static let caretSize: CGFloat = 12
  fileprivate static let labelHorizontalMargin: CGFloat = .spacingSm
  fileprivate static let labelVerticalMargin: CGFloat = .spacingSm
  fileprivate static let labelMaxWidth: CGFloat =
    tipViewDefaultMaxWidth - (.labelHorizontalMargin * 2)
  fileprivate static let labelMinWidth: CGFloat = 64 - (.labelHorizontalMargin * 2)
}

extension CGFloat {
  static let tipViewDefaultMaxWidth: CGFloat = 256
}
