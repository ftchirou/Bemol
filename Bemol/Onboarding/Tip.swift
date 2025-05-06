import Foundation

struct Tip: Equatable {
  enum Target {
    case titleView
    case startStopButton
    case repeatButton
    case previousButton
    case nextButton
    case randomButton
    case homeButton
    case accuracyRing
    case configureLevelButton
    case keyboard
  }

  let target: Target
  let title: String
  let message: String
  let actionTitle: String

  init(target: Target, title: String, message: String, actionTitle: String) {
    self.target = target
    self.title = title
    self.message = message
    self.actionTitle = actionTitle
  }
}
