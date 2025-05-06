import UIKit


@MainActor
final class TipPresenter {
  private init() {}

  static func present(
    edge: TipView.Edge,
    title: String,
    message: String,
    action: TipView.Action,
    onView view: UIView
  ) -> TipView? {
    guard let window = view.window else { return nil }

    let targetViewFrame = view.convert(view.bounds, to: window)
    let tipView = TipView(
      edge: edge,
      title: title,
      message: message,
      action: action
    )
    tipView.translatesAutoresizingMaskIntoConstraints = true
    tipView.alpha = 0
    window.addSubview(tipView)
    window.bringSubviewToFront(tipView)
    tipView.maxWidth = preferredMaxWidth(for: tipView, on: view)
    tipView.isUserInteractionEnabled = true

    switch edge {
    case .topLeft:
      tipView.frame = CGRect(
        x: targetViewFrame.midX - .spacingSm - .caretSize / 2,
        y: targetViewFrame.maxY + .spacingXs,
        width: tipView.intrinsicContentSize.width,
        height: tipView.intrinsicContentSize.height
      )
    case .topCenter:
      tipView.frame = CGRect(
        x: targetViewFrame.midX - tipView.intrinsicContentSize.width / 2,
        y: targetViewFrame.maxY + .spacingXs,
        width: tipView.intrinsicContentSize.width,
        height: tipView.intrinsicContentSize.height
      )
    case .topRight:
      tipView.frame = CGRect(
        x: targetViewFrame.midX - tipView.intrinsicContentSize.width + (.spacingSm + .caretSize / 2),
        y: targetViewFrame.maxY + .spacingXs,
        width: tipView.intrinsicContentSize.width,
        height: tipView.intrinsicContentSize.height
      )
    case .leftBottom:
      tipView.frame = CGRect(
        x: targetViewFrame.maxX + .spacingSm,
        y: targetViewFrame.maxY - (tipView.intrinsicContentSize.height + .spacingLg * 2),
        width: tipView.intrinsicContentSize.width,
        height: tipView.intrinsicContentSize.height
      )
    }

    UIView.animate(
      withDuration: .animationDuration,
      delay: 0,
      options: [.curveEaseIn],
      animations: {
        tipView.alpha = 1
      },
      completion: { _ in }
    )

    return tipView
  }

  static private func preferredMaxWidth(for tipView: TipView, on view: UIView) -> CGFloat {
    guard let window = view.window else { return .tipViewDefaultMaxWidth }
    let bounds = view.convert(view.bounds, to: window)

    switch tipView.edge {
    case .topLeft:
      return window.frame.width - bounds.midX
    case .topRight:
      return window.frame.width - (window.frame.maxX - bounds.midX)
    case .topCenter, .leftBottom:
      if bounds.midX <= window.frame.midX {
        return (bounds.midX - .spacingSm) * 2
      } else {
        return ((window.frame.maxX - bounds.midX) - .spacingSm) * 2
      }
    }
  }

  static func dismiss(_ tipView: TipView, completion: @escaping () -> Void) {
    guard tipView.superview != nil else {
      completion()
      return
    }

    UIView.animate(
      withDuration: .animationDuration,
      delay: 0,
      options: [.curveEaseOut],
      animations: {
        tipView.alpha = 0
      },
      completion: { _ in
        if tipView.superview != nil {
          tipView.removeFromSuperview()
        }
        completion()
      }
    )
  }
}

// MARK: - Constants

private extension TimeInterval {
  static let animationDuration: TimeInterval = 0.15
}

private extension CGFloat {
  static let caretSize: CGFloat = 12
}
