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
  init(type: ButtonType, title: String, size: ButtonSize, foregroundColor: Color) {
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
#endif


#if os(iOS)
import UIKit

@MainActor
final class Button: Control {
  init(type: ButtonType, title: String, size: ButtonSize, foregroundColor: Color) {
    super.init(frame: .zero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
#endif
