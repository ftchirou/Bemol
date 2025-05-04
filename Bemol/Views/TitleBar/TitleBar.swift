///
/// TitleBar.swift
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

struct TitleBarDelegate {
  let didPressCancelButton: () -> Void
  let didPressDoneButton: () -> Void
}

@MainActor
final class TitleBar: UIView {
  // MARK: - Subviews
  private lazy var cancelButton: UIButton = {
    let button = UIButton(configuration: .plain())
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.title = String(localized: "cancel")
    button.configuration?.baseForegroundColor = .systemOrange
    button.configuration?.titleAlignment = .center
    button.configuration?.buttonSize = .small
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressCancelButton() },
      for: .touchUpInside
    )


    return button
  }()

  private lazy var label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .body
    label.textAlignment = .center
    label.textColor = .buttonForeground
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true

    return label
  }()

  private lazy var doneButton: UIButton = {
    let button = UIButton(configuration: .filled())
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.title = String(localized: "done")
    button.configuration?.baseBackgroundColor = .systemOrange
    button.configuration?.baseForegroundColor = .buttonForeground
    button.configuration?.titleAlignment = .center
    button.configuration?.buttonSize = .small
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressDoneButton() },
      for: .touchUpInside
    )

    return button
  }()

  // MARK: - API

  var delegate: TitleBarDelegate?

  var title: AttributedString? {
    didSet {
      if oldValue == nil || title != oldValue {
        label.attributedText = title.flatMap { NSAttributedString($0) }
      }
    }
  }

  var isCancelButtonHidden: Bool = false {
    didSet {
      cancelButton.isHidden = isCancelButtonHidden
    }
  }

  var isDoneButtonHidden: Bool = false {
    didSet {
      doneButton.isHidden = isDoneButtonHidden
    }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpViewHierarchy()
    setUpAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Private

  private func setUpAppearance() {
    backgroundColor = .black
  }

  private func setUpViewHierarchy() {
    addSubview(cancelButton)
    addSubview(label)
    addSubview(doneButton)

    NSLayoutConstraint.activate([
      cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingMd),
      cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor),

      label.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: .spacingMd),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      label.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -.spacingMd),

      doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingMd),
      doneButton.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }
}
