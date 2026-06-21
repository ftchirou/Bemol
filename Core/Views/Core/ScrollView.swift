///
/// ScrollView.swift
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

public typealias ScrollView = NSScrollView

extension ScrollView {
  var showsHorizontalScrollIndicator: Bool {
    get { hasHorizontalScroller }
    set { hasHorizontalScroller = newValue }
  }

  var showsVerticalScrollIndicator: Bool {
    get { hasVerticalScroller }
    set { hasVerticalScroller = newValue }
  }

  var bounces: Bool {
    get { false }
    set { }
  }

  var isScrollEnabled: Bool {
    // TODO
    get { true }
    set {}
  }

  func addContentView(_ contentView: NSView) {
    let clipView = NSClipView()
    clipView.translatesAutoresizingMaskIntoConstraints = false
    clipView.documentView = contentView
    
    self.contentView = clipView
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
      contentView.topAnchor.constraint(equalTo: clipView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: clipView.bottomAnchor),
    ])
  }

  func scrollTo(_ point: CGPoint, animated: Bool) {
    guard animated else {
      scroll(contentView, to: point)
      return
    }

    // https://stackoverflow.com/a/49672274
    NSAnimationContext.beginGrouping()
    NSAnimationContext.current.duration = 0.2
    contentView.animator().setBoundsOrigin(point)
    reflectScrolledClipView(contentView)
    NSAnimationContext.endGrouping()
  }
}
#endif

#if os(iOS)
import UIKit

public typealias ScrollView = UIScrollView

extension ScrollView {
  func addContentView(_ contentView: UIView) {
    addSubview(contentView)

    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
      contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
      contentLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])
  }

  func scrollTo(_ point: CGPoint, animated: Bool) {
    setContentOffset(point, animated: animated)
  }
}
#endif
