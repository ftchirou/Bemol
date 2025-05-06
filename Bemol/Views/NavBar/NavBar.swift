///
/// NavBar.swift
/// Bemol
///
/// Copyright 2025 Faiçal Tchirou
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

import Foundation
import UIKit

struct NavBarDelegate {
  let didPressHomeButton: () -> Void
  let didPressRandomButton: () -> Void
  let didPressPreviousButton: () -> Void
  let didPressNextButton: () -> Void
  let didPressConfigureButton: () -> Void
  let didPressStartStopButton: () -> Void
  let didPressRepeatButton: () -> Void
  let didPressProgressButton: () -> Void
  let didDismissTip: () -> Void
}

@MainActor
final class NavBar: UIView {
  // MARK: - Subviews

  private lazy var navButtonConfiguration: UIButton.Configuration = {
    var configuration = UIButton.Configuration.plain()
    configuration.baseForegroundColor = .buttonForeground
    configuration.titleAlignment = .center
    configuration.buttonSize = .medium

    return configuration
  }()

  private lazy var homeButton: UIButton = {
    let button = UIButton(configuration: navButtonConfiguration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.image = UIImage(systemName: "c.circle.fill")
    button.configuration?.imageColorTransformer = menuButtonImageColorTransformer(for: button)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.accessibilityLabel = String(localized: "goToCMajor")
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressHomeButton() },
      for: .touchUpInside
    )


    return button
  }()

  private lazy var randomButton: UIButton = {
    let button = UIButton(configuration: navButtonConfiguration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.image = UIImage(systemName: "shuffle.circle.fill")
    button.configuration?.imageColorTransformer = menuButtonImageColorTransformer(for: button)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.accessibilityLabel = String(localized: "goToRandomLevel")
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressRandomButton() },
      for: .touchUpInside
    )

    return button
  }()

  private lazy var previousButton: UIButton = {
    let button = UIButton(configuration: navButtonConfiguration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.image = UIImage(systemName: "chevron.left")
    button.configuration?.imageColorTransformer = menuButtonImageColorTransformer(for: button)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.accessibilityLabel = String(localized: "goToPreviousLevel")
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressPreviousButton() },
      for: .touchUpInside
    )


    return button
  }()

  private lazy var titleView: TitleView = {
    let view = TitleView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.setContentCompressionResistancePriority(.required, for: .horizontal)

    return view
  }()

  private lazy var configureButton: UIButton = {
    let button = UIButton(configuration: .borderless())

    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.baseForegroundColor = .buttonForeground
    button.configuration?.titleAlignment = .center
    button.configuration?.buttonSize = .mini
    button.configuration?.image = UIImage(systemName: "slider.vertical.3")
    button.configuration?.imageColorTransformer = menuButtonImageColorTransformer(for: button)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.accessibilityLabel = String(localized: "configureLevel")
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressConfigureButton() },
      for: .touchUpInside
    )

    return button
  }()

  private lazy var nextButton: UIButton = {
    let button = UIButton(configuration: navButtonConfiguration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.image = UIImage(systemName: "chevron.right")
    button.configuration?.imageColorTransformer = menuButtonImageColorTransformer(for: button)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.accessibilityLabel = String(localized: "goToNextLevel")
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressNextButton() },
      for: .touchUpInside
    )

    return button
  }()

  private lazy var startStopButton: UIButton = {
    let button = UIButton(configuration: navButtonConfiguration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.image = UIImage(systemName: "play.fill")
    button.configuration?.imageColorTransformer = menuButtonImageColorTransformer(for: button)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.accessibilityLabel = String(localized: "startSession")
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressStartStopButton() },
      for: .touchUpInside
    )

    return button
  }()

  private lazy var repeatButton: UIButton = {
    let button = UIButton(configuration: navButtonConfiguration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.image = UIImage(systemName: "repeat")
    button.configuration?.imageColorTransformer = menuButtonImageColorTransformer(for: button)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.accessibilityLabel = String(localized: "replayQuestion")
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressRepeatButton() },
      for: .touchUpInside
    )

    return button
  }()

  private lazy var loadingIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.color = .buttonForeground
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.setContentCompressionResistancePriority(.required, for: .horizontal)

    return view
  }()

  private lazy var scoreLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .body
    label.textAlignment = .left
    label.textColor = .buttonForeground
    label.adjustsFontForContentSizeCategory = true
    label.adjustsFontSizeToFitWidth = true

    return label
  }()

  private lazy var stackView: UIStackView = {
    let view = UIStackView(
      arrangedSubviews: [
        homeButton,
        randomButton,
        previousButton,
        nextButton,
        titleView,
        configureButton,
        startStopButton,
        repeatButton,
        loadingIndicator,
      ]
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.distribution = .fillProportionally
    view.alignment = .fill
    view.spacing = 0

    return view
  }()

  private lazy var accuracyRing: AccuracyRing = {
    let button = AccuracyRing(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addAction(
      UIAction { [weak self] _ in self?.delegate?.didPressProgressButton() },
      for: .touchUpInside)

    return button
  }()

  private weak var tipView: TipView? = nil

  // MARK: - API

  var delegate: NavBarDelegate?

  var state: NavBarState? {
    didSet {
      guard oldValue == nil || state != oldValue else {
        return
      }

      let isLoading = state?.isLoading ?? false
      let isHomeButtonEnabled = state?.isHomeButtonEnabled ?? false
      let isRandomButtonEnabled = state?.isRandomButtonEnabled ?? false
      let isPreviousButtonEnabled = state?.isPreviousButtonEnabled ?? false
      let isNextButtonEnabled = state?.isNextButtonEnabled ?? false
      let isConfigureButtonEnabled = state?.isConfigureButtonEnabled ?? false
      let isStartStopButtonEnabled = state?.isStartStopButtonEnabled ?? false

      homeButton.isEnabled = isHomeButtonEnabled && !isLoading
      randomButton.isEnabled = isRandomButtonEnabled && !isLoading
      previousButton.isEnabled = isPreviousButtonEnabled && !isLoading
      nextButton.isEnabled = isNextButtonEnabled && !isLoading
      titleView.title = state?.title
      configureButton.isEnabled = isConfigureButtonEnabled && !isLoading
      startStopButton.isEnabled = isStartStopButtonEnabled && !isLoading
      startStopButton.configuration?.image = if (state?.startStopButtonMode ?? .start) == .start {
        UIImage(systemName: "play.fill")
      } else {
        UIImage(systemName: "stop.fill")
      }
      repeatButton.isHidden = state?.isRepeatButtonHidden ?? true
      repeatButton.isEnabled = state?.isRepeatButtonEnabled ?? false
      scoreLabel.isHidden = state?.isScoreLabelHidden ?? true
      scoreLabel.attributedText = state?.scoreText.flatMap { NSAttributedString($0) }
      scoreLabel.accessibilityLabel = state?.scoreAccessibilityText
      accuracyRing.isEnabled = !isLoading && state?.isAccuracyRingEnabled ?? false
      accuracyRing.accuracy = state?.accuracy ?? 0
      accuracyRing.accessibilityLabel = state?.accuracyRingAccessibilityText

      if isLoading {
        loadingIndicator.startAnimating()
      } else {
        loadingIndicator.stopAnimating()
      }

      startStopButton.accessibilityLabel = if (state?.startStopButtonMode ?? .start) == .start {
        String(localized: "startSession")
      } else {
        String(localized: "stopSession")
      }

      if let tip = state?.tip {
        if oldValue?.tip == nil {
          DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.handle(tip)
          }
        } else {
          handle(tip)
        }
      }
    }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpViewHierarchy()
    setUpAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Private

  private func setUpAppearance() {
    backgroundColor = .black
    accessibilityTraits = .header
    accessibilityElements = [
      homeButton, randomButton, previousButton, nextButton, titleView,
      configureButton, startStopButton, repeatButton, scoreLabel, accuracyRing
    ]
  }

  private func setUpViewHierarchy() {
    addSubview(stackView)
    addSubview(accuracyRing)
    addSubview(scoreLabel)

    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingMd),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

      accuracyRing.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingMd),
      accuracyRing.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65),
      accuracyRing.widthAnchor.constraint(equalTo: accuracyRing.heightAnchor),
      accuracyRing.centerYAnchor.constraint(equalTo: centerYAnchor),

      scoreLabel.trailingAnchor.constraint(equalTo: accuracyRing.leadingAnchor, constant: -.spacingSm),
      scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: .spacingSm),
    ])
  }

  private func menuButtonImageColorTransformer(
    for button: UIButton
  ) -> UIConfigurationColorTransformer {
    UIConfigurationColorTransformer { _ in
      if button.isHighlighted {
        return .buttonForeground.withAlphaComponent(0.8)
      }

      if !button.isEnabled {
        return .buttonForeground.withAlphaComponent(0.5)
      }

      return .buttonForeground
    }
  }
}

// MARK: - TipHandler

extension NavBar: TipHandler {
  func handle(_ tip: Tip) {
    if let view = targetView(for: tip) {
      tipView = TipPresenter.present(
        edge: edge(for: tip),
        title: tip.title,
        message: tip.message,
        action: TipView.Action(title: tip.actionTitle) { [weak self] in
          self?.dismissTipView()
        },
        onView: view
      )
    }
  }

  private func dismissTipView() {
    if let tooltip = tipView {
      TipPresenter.dismiss(tooltip) { [weak self] in
        self?.tipView?.removeFromSuperview()
        self?.tipView = nil
        self?.delegate?.didDismissTip()
      }
    }
  }

  private func targetView(for tip: Tip) -> UIView? {
    switch tip.target {
    case .titleView:
      titleView
    case .homeButton:
      homeButton
    case .randomButton:
      randomButton
    case .previousButton:
      previousButton
    case .nextButton:
      nextButton
    case .configureLevelButton:
      configureButton
    case .startStopButton:
      startStopButton
    case .repeatButton:
      repeatButton
    case .accuracyRing:
      accuracyRing
    case .keyboard:
      nil
    }
  }

  private func edge(for tip: Tip) -> TipView.Edge {
    switch tip.target {
    case .titleView:
        .topCenter
    case .homeButton:
        .topLeft
    case .randomButton:
        .topLeft
    case .previousButton:
        .topLeft
    case .nextButton:
        .topCenter
    case .configureLevelButton:
        .topCenter
    case .startStopButton:
        .topCenter
    case .repeatButton:
        .topCenter
    case .accuracyRing:
        .topRight
    case .keyboard:
        .topCenter
    }
  }
}
