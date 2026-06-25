///
/// Action.swift
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

enum ButtonType {
  case plain
}

enum ButtonSize {
  case small
}

#if os(macOS)
import AppKit

@MainActor
final class Button: Control {

  // MARK: - Factories

  static func secondary(title: String) -> Button {
    let button = NSButton(title: title, target: nil, action: nil)
    button.setUp()
    button.tintProminence = .secondary
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.sizeToFit()

    return .init(button)
  }

  static func primary(title: String) -> Button {
    let button = NSButton(title: title, target: nil, action: nil)
    button.setUp()
    button.tintProminence = .primary
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.sizeToFit()

    return .init(button)
  }

  // MARK: - Private API

  private let button: NSButton
  private var primaryAction: Action? = nil

  private init(_ button: NSButton) {
    self.button = button
    super.init(frame: .zero)

    addSubview(button)
    LayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  override func addAction(_ action: Action, for controlEvents: Control.Event) {
    self.primaryAction = action
    button.action = #selector(performAction)
    button.target = self
  }

  @objc private func performAction() {
    primaryAction?.perform()
  }
}
#endif


#if os(iOS)
import UIKit
typealias Button = UIButton

extension Button {
  static func secondary(title: String) -> Button {
    let button = UIButton(configuration: .plain())
    button.setUp()
    button.configuration?.title = title
    button.configuration?.baseForegroundColor = .systemOrange
    button.configuration?.titleAlignment = .center
    button.configuration?.buttonSize = .small
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)

    return button
  }

  static func primary(title: String) -> Button {
    let button = UIButton(configuration: .filled())
    button.setUp()
    button.configuration?.title = String(localized: "done")
    button.configuration?.baseBackgroundColor = .systemOrange
    button.configuration?.baseForegroundColor = .buttonForeground
    button.configuration?.titleAlignment = .center
    button.configuration?.buttonSize = .small
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)

    return button
  }
}
#endif
