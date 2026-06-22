///
/// LayoutConstraint.swift
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

typealias LayoutConstraint = NSLayoutConstraint

extension LayoutConstraint.Priority {
  static let none = LayoutConstraint.Priority(1)
}
#endif


#if os(iOS)
import UIKit

typealias LayoutConstraint = NSLayoutConstraint

extension UILayoutPriority {
  static let none = UILayoutPriority(1)
}
#endif
