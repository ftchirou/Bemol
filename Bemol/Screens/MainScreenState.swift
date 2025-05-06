import Foundation
import UIKit

struct MainScreenState {
  var isLoading: Bool
  var key: NoteName
  var isPreviousButtonEnabled: Bool
  var isNextButtonEnabled: Bool
  var title: AttributedString?
  var isConfigureButtonEnabled: Bool
  var isStartStopButtonEnabled: Bool
  var startStopButtonMode: NavBarState.StartStopMode = .start
  var isRepeatButtonHidden: Bool
  var isRepeatButtonEnabled: Bool
  var isScoreLabelHidden: Bool
  var scoreText: AttributedString?
  var scoreAccessibilityText: String?
  var accuracy: Float
  var isAccuracyRingEnabled: Bool
  var accuracyRingAccessibilityText: String?
  var isKeyboardEnabled: Bool
  var activeNotes: [Note]
  var highlightedNote: (Note, UIColor)?
  var tip: Tip?
}

extension MainScreenState {
  var navBarState: NavBarState {
    NavBarState(
      isLoading: isLoading,
      isPreviousButtonEnabled: isPreviousButtonEnabled,
      isNextButtonEnabled: isNextButtonEnabled,
      title: title,
      isConfigureButtonEnabled: isConfigureButtonEnabled,
      isStartStopButtonEnabled: isStartStopButtonEnabled,
      startStopButtonMode: startStopButtonMode,
      isRepeatButtonHidden: isRepeatButtonHidden,
      isRepeatButtonEnabled: isRepeatButtonEnabled,
      isScoreLabelHidden: isScoreLabelHidden,
      scoreText: scoreText,
      scoreAccessibilityText: scoreAccessibilityText,
      accuracy: accuracy,
      isAccuracyRingEnabled: isAccuracyRingEnabled,
      accuracyRingAccessibilityText: accuracyRingAccessibilityText,
      tip: tip
    )
  }
}
