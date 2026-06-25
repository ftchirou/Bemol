///
/// Control.swift
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

@MainActor
open class Control: NSControl {

  // MARK: - Event

  public struct Event: Hashable {
    static var touchUpInside: Control.Event = .init(rawValue: 1)
    static var touchDown: Control.Event = .init(rawValue: 2)

    private let rawValue: UInt

    init(rawValue: UInt) {
      self.rawValue = rawValue
    }
  }

  // MARK: -

  open var isSelected: Bool = false {
    didSet {
      isHighlighted = isSelected
    }
  }

  // MARK: - Actions

  private var actions: [Control.Event: Action] = [:]

  open func addAction(
    _ action: Action,
    for controlEvents: Control.Event
  ) {
    actions[controlEvents] = action
  }

  open func beginTracking(_ touch: Touch, with event: UIEvent?) -> Bool {
    return true
  }

  open func endTracking(_ touch: Touch?, with event: UIEvent?) {
  }

  func sendActions(for event: Control.Event) {
    actions[event]?.perform()
  }

  override open func mouseDown(with event: NSEvent) {
    if isEnabled && beginTracking(Touch(), with: event) {
      actions[.touchDown]?.perform()
    }
  }

  override open func mouseUp(with event: NSEvent) {
    guard isEnabled else { return }

    endTracking(nil, with: event)
    actions[.touchUpInside]?.perform()
  }
}
#endif


#if os(iOS)
import UIKit
typealias Control = UIControl
#endif
