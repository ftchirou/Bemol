///
/// AppDelegate.swift
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

import AppKit
import Cocoa
import os

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow?

  // MARK: - Environment & Loop

  private lazy var environment = AppEnvironment(
    notePlayer: MIDINotePlayer(),
    practiceManager: CyclicPracticeManager(
      storage: FileSessionStorage(fileManager: .default),
      levelGenerator: DiatonicLevelGenerator(),
      noteResolutionGenerator: DiatonicNoteResolutionGenerator(),
      preferences: UserDefaults.standard
    ),
    tipProvider: OnboardingTipProvider(),
    preferences: UserDefaults.standard,
    logger: Logger()
  )

  private lazy var loop: AppLoop = {
    let loop = AppLoop(
      environment: environment,
      initialState: AppState()
    )
    loop.delegate = AppLoopDelegate(
      didUpdateState: { [weak self] in self?.didUpdateState($0) }
    )

    return loop
  }()

  private lazy var app = App(
    environment: environment,
    loop: loop
  )

  // MARK: - Toolbar Items

  private lazy var startStopButtonToolbarItem: NSToolbarItem = {
    let item = NSToolbarItem(itemIdentifier: .startStopSessionButton)
    item.toolTip = String(localized: "startSession")
    item.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
    item.isEnabled = true
    item.action = #selector(startStopSessionButtonTapped)
    item.target = self

    return item
  }()

  private lazy var accuracyRingToolbarItem: NSToolbarItem = {
    let item = NSToolbarItem(itemIdentifier: .accuracyButton)
    item.toolTip = String(localized: "accuracyInLevel")
    item.view = accuracyRing
    item.isEnabled = true

    return item
  }()

  private lazy var scoreLabelToolbarItem: NSToolbarItem = {
    let item = NSToolbarItem(itemIdentifier: .scoreLabel)
    item.toolTip = String(localized: "yourScore")
    item.view = scoreLabel

    return item
  }()

  private lazy var scoreLabel: Label = {
    let label = Label()
    label.setUp()
    label.font = .body
    label.textAlignment = .left

    return label
  }()

  private lazy var accuracyRing: AccuracyRing = {
    let ring = AccuracyRing()
    ring.setUp()
    ring.strokeWidth = 3
    ring.widthAnchor.constraint(equalToConstant: 92).isActive = true
    ring.heightAnchor.constraint(equalToConstant: 32).isActive = true
    ring.addAction(
      Action { [weak self] _ in self?.accuracyButtonTapped() },
      for: .touchUpInside
    )

    return ring
  }()

  private lazy var isToolbarItemEnabled: [NSToolbarItem.Identifier: Bool] = [:]

  // MARK: - Main

  static func main() {
    let delegate = AppDelegate()
    NSApplication.shared.delegate = delegate

    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
  }

  // MARK: - Lifecycle

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let toolbar = NSToolbar()
    toolbar.displayMode = .iconOnly
    toolbar.delegate = self

    window = NSWindow(contentViewController: rootViewController())
    window?.appearance = NSAppearance(named: .vibrantDark)
    window?.title = String(localized: "bemol")
    window?.subtitle = String(localized: "earTraining")
    window?.toolbar = toolbar
    window?.isReleasedWhenClosed = true
    window?.styleMask.insert(.borderless)
    window?.styleMask.remove(.resizable)
    window?.styleMask.insert(.unifiedTitleAndToolbar)
    window?.makeKeyAndOrderFront(nil)

    loop.dispatch(.didLoad)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    false
  }

  // MARK: - Private Helpers

  private func rootViewController() -> NSViewController {
    app.view.setUp()

    let viewController = NSViewController()
    viewController.view.frame = NSRect(x: 0, y: 0, width: 860, height: 340)
    viewController.view.setUp()
    viewController.view.backgroundStyle = .black
    viewController.view.addSubview(app.view)

    NSLayoutConstraint.activate([
      app.view.leadingAnchor
        .constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
      app.view.topAnchor
        .constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
      app.view.trailingAnchor
        .constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor),
      app.view.bottomAnchor
        .constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
    ])

    return viewController
  }
}

// MARK: - AppLoopDelegate

extension AppDelegate {
  func didUpdateState(_ state: AppState) {
    app.setState(state)
    window?.subtitle = state.level == nil ? String(localized: "earTraining") : state.level!.title
    updateToolbar(state.mainScreenState.navBarState)
  }

  func updateToolbar(_ state: NavBarState) {
    isToolbarItemEnabled[.firstLevelButton] = state.isHomeButtonEnabled
    isToolbarItemEnabled[.randomLevelButton] = state.isRandomButtonEnabled
    isToolbarItemEnabled[.previousLevelButton] = state.isPreviousButtonEnabled
    isToolbarItemEnabled[.nextLevelButton] = state.isNextButtonEnabled
    isToolbarItemEnabled[.configureLevelButton] = state.isConfigureButtonEnabled
    isToolbarItemEnabled[.startStopSessionButton] = state.isStartStopButtonEnabled
    isToolbarItemEnabled[.repeatButton] = state.isRepeatButtonEnabled
    isToolbarItemEnabled[.accuracyButton] = state.isAccuracyRingEnabled

    startStopButtonToolbarItem.image = NSImage(
      systemSymbolName: state.startStopButtonMode == .start ? "play.fill" : "stop.fill",
      accessibilityDescription: nil
    )
    startStopButtonToolbarItem.toolTip = state.startStopButtonMode == .start
      ? String(localized: "startSession")
      : String(localized: "stopSession")

    scoreLabel.attributedText = state.scoreText.flatMap { NSAttributedString($0) }
    scoreLabel.isHidden = state.isScoreLabelHidden
    scoreLabelToolbarItem.toolTip = state.scoreAccessibilityText

    accuracyRing.accuracy = state.accuracy
    accuracyRing.isEnabled = state.isAccuracyRingEnabled
    accuracyRingToolbarItem.toolTip = switch (state.startStopButtonMode, state.isAccuracyRingEnabled) {
    case (.start, true):
      String(localized: "accuracyInLevelWithCTA")
    case (.start, false):
      String(localized: "accuracyInLevel")
    case (.stop, true):
      String(localized: "accuracyInSessionWithCTA")
    case (.stop, false):
      String(localized: "accuracyInSession")
    }

    NSApplication.shared.setWindowsNeedUpdate(true)
  }
}

// MARK: - NSToolbarDelegate

extension AppDelegate: NSToolbarDelegate {
  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .levelSelectionGroup,
      .levelNavigationGroup,
      .practiceSessionGroup,
      .scoreLabel,
      .accuracyButton,
    ]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .levelSelectionGroup,
      .levelNavigationGroup,
      .practiceSessionGroup,
      .scoreLabel,
      .accuracyButton,
    ]
  }

  func toolbar(
    _ toolbar: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar flag: Bool
  ) -> NSToolbarItem? {
    switch itemIdentifier {
    case .levelSelectionGroup:
      let firstLevelButtonItem = NSToolbarItem(itemIdentifier: .firstLevelButton)
      firstLevelButtonItem.toolTip = String(localized: "goToCMajor")
      firstLevelButtonItem.image = NSImage(systemSymbolName: "c.circle.fill", accessibilityDescription: nil)
      firstLevelButtonItem.action = #selector(firstLevelButtonTapped)
      firstLevelButtonItem.target = self
      firstLevelButtonItem.isEnabled = isToolbarItemEnabled[.firstLevelButton] ?? false

      let randomLevelButtonItem = NSToolbarItem(itemIdentifier: .randomLevelButton)
      randomLevelButtonItem.toolTip = String(localized: "goToRandomLevel")
      randomLevelButtonItem.image = NSImage(systemSymbolName: "shuffle.circle.fill", accessibilityDescription: nil)
      randomLevelButtonItem.action = #selector(randomLevelButtonTapped)
      randomLevelButtonItem.target = self
      randomLevelButtonItem.isEnabled = true

      let group = NSToolbarItemGroup(itemIdentifier: itemIdentifier)
      group.subitems = [firstLevelButtonItem, randomLevelButtonItem]

      return group

    case .levelNavigationGroup:
      let previousLevelButtonItem = NSToolbarItem(itemIdentifier: .previousLevelButton)
      previousLevelButtonItem.toolTip = String(localized: "goToPreviousLevel")
      previousLevelButtonItem.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)
      previousLevelButtonItem.action = #selector(previousLevelButtonTapped)
      previousLevelButtonItem.target = self
      previousLevelButtonItem.isEnabled = true

      let nextLevelButtonItem = NSToolbarItem(itemIdentifier: .nextLevelButton)
      nextLevelButtonItem.toolTip = String(localized: "goToNextLevel")
      nextLevelButtonItem.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
      nextLevelButtonItem.isEnabled = true
      nextLevelButtonItem.action = #selector(nextLevelButtonTapped)
      nextLevelButtonItem.target = self

      let group = NSToolbarItemGroup(itemIdentifier: itemIdentifier)
      group.subitems = [previousLevelButtonItem, nextLevelButtonItem]

      return group

    case .practiceSessionGroup:
      let configureLevelButtonItem = NSToolbarItem(itemIdentifier: .configureLevelButton)
      configureLevelButtonItem.toolTip = String(localized: "configureLevel")
      configureLevelButtonItem.image = NSImage(systemSymbolName: "slider.vertical.3", accessibilityDescription: nil)
      configureLevelButtonItem.isEnabled = true
      configureLevelButtonItem.action = #selector(configureLevelButtonTapped)
      configureLevelButtonItem.target = self

      let repeatButtonItem = NSToolbarItem(itemIdentifier: .repeatButton)
      repeatButtonItem.toolTip = String(localized: "replayQuestion")
      repeatButtonItem.image = NSImage(systemSymbolName: "repeat", accessibilityDescription: nil)
      repeatButtonItem.isEnabled = true
      repeatButtonItem.action = #selector(repeatButtonTapped)
      repeatButtonItem.target = self

      let group = NSToolbarItemGroup(itemIdentifier: itemIdentifier)
      group.subitems = [configureLevelButtonItem, startStopButtonToolbarItem, repeatButtonItem]

      return group

    case .scoreLabel:
      return scoreLabelToolbarItem

    case .accuracyButton:
      return accuracyRingToolbarItem

    default:
      return nil
    }
  }
}

// MARK: - Toolbar Actions

extension AppDelegate {
  @objc private func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
    isToolbarItemEnabled[item.itemIdentifier] ?? false
  }

  @objc private func firstLevelButtonTapped() {
    loop.dispatch(.didPressHomeButton)
  }

  @objc private func randomLevelButtonTapped() {
    loop.dispatch(.didPressRandomButton)
  }

  @objc private func previousLevelButtonTapped() {
    loop.dispatch(.didPressPreviousLevelButton)
  }

  @objc private func nextLevelButtonTapped() {
    loop.dispatch(.didPressNextLevelButton)
  }

  @objc private func configureLevelButtonTapped() {
    loop.dispatch(.didPressConfigureLevelButton)
  }

  @objc private func startStopSessionButtonTapped() {
    loop.dispatch(.didPressStartStopLevelButton)
  }

  @objc private func repeatButtonTapped() {
    loop.dispatch(.didPressRepeatQuestionButton)
  }

  @objc private func accuracyButtonTapped() {
    loop.dispatch(.didPressAccuracyRing)
  }
}

// MARK: - Toolbar Identifiers

private extension NSToolbarItem.Identifier {
  static let levelSelectionGroup = NSToolbarItem.Identifier(rawValue: "levelSelectonGroup")
  static let levelNavigationGroup = NSToolbarItem.Identifier(rawValue: "levelNavigationGroup")
  static let practiceSessionGroup = NSToolbarItem.Identifier(rawValue: "practiceSessionGroup")

  static let firstLevelButton = NSToolbarItem.Identifier(rawValue: "firstLevelButton")
  static let randomLevelButton = NSToolbarItem.Identifier(rawValue: "randomLevelButton")
  static let previousLevelButton = NSToolbarItem.Identifier(rawValue: "previousLevelButton")
  static let nextLevelButton = NSToolbarItem.Identifier(rawValue: "nextLevelButton")
  static let configureLevelButton = NSToolbarItem.Identifier(rawValue: "configureLevelButton")
  static let startStopSessionButton = NSToolbarItem.Identifier(rawValue: "startStopSessionButton")
  static let repeatButton = NSToolbarItem.Identifier(rawValue: "repeatButton")
  static let scoreLabel = NSToolbarItem.Identifier(rawValue: "scoreLabel")
  static let accuracyButton = NSToolbarItem.Identifier(rawValue: "accuracyButton")
}
