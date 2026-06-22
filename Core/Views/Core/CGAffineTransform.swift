import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#endif

extension CGAffineTransform {
  static func rotation(angle: CGFloat) -> CGAffineTransform {
#if os(iOS)
    CGAffineTransform(rotationAngle: angle)
#endif

#if os(macOS)
    CGAffineTransform(rotationAngle: -angle)
#endif
  }
}
