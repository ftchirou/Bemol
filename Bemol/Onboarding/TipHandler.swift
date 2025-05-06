import Foundation

@MainActor
protocol TipHandler {
  func handle(_ tip: Tip)
}
