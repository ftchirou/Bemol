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

  private lazy var startStopButton: NSToolbarItem = {
    let item = NSToolbarItem(itemIdentifier: .startStopSessionButton)
    item.toolTip = String(localized: "startSession")
    item.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
    item.isEnabled = true
    item.action = #selector(startStopSessionButtonTapped)
    item.target = self

    return item
  }()

  private lazy var scoreLabel: Label = {
    let label = Label()
    label.setUp()
    label.font = .body
    label.textAlignment = .left

    return label
  }()

  private lazy var accuracyRing: NSProgressIndicator = {
    let indicator = NSProgressIndicator()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.controlSize = NSControl.ControlSize.regular
    indicator.style = .spinning
    indicator.minValue = 0
    indicator.maxValue = 1
    indicator.isIndeterminate = false

    return indicator
  }()

  private lazy var accuracyRingButton: NSButton = {
    let button = NSButton(title: "", target: self, action: #selector(accuracyButtonTapped))
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isTransparent = true

    return button
  }()

  private lazy var accuracyLabel: Label = {
    let label = Label()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 6.5, weight: .semibold)

    return label
  }()

  private lazy var accuracyView: NSView = {
    let view = NSView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(accuracyRing)
    view.addSubview(accuracyLabel)
    view.addSubview(accuracyRingButton)

    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(equalTo: accuracyRing.widthAnchor),
      view.heightAnchor.constraint(equalTo: accuracyRing.heightAnchor),

      accuracyRing.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      accuracyRing.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      accuracyRing.topAnchor.constraint(equalTo: view.topAnchor),
      accuracyRing.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      accuracyRingButton.leadingAnchor.constraint(equalTo: accuracyRing.leadingAnchor),
      accuracyRingButton.trailingAnchor.constraint(equalTo: accuracyRing.trailingAnchor),
      accuracyRingButton.topAnchor.constraint(equalTo: accuracyRing.topAnchor),
      accuracyRingButton.bottomAnchor.constraint(equalTo: accuracyRing.bottomAnchor),

      accuracyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      accuracyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])

    return view
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
    toolbar.delegate = self

    window = NSWindow(contentViewController: rootViewController())
    window?.appearance = NSAppearance(named: .vibrantDark)
    window?.title = String(localized: "bemol")
    window?.subtitle = "Ear training"
    window?.toolbar = toolbar
    window?.isReleasedWhenClosed = true
    window?.styleMask.insert(.borderless)
    window?.styleMask.remove(.resizable)
    window?.styleMask.insert(.unifiedTitleAndToolbar)
    window?.makeKeyAndOrderFront(nil)

    loop.dispatch(.didLoad)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // MARK: - Private Helpers

  private func rootViewController() -> NSViewController {
    app.view.setUp()

    let viewController = NSViewController()
    viewController.view.frame = NSRect(x: 0, y: 0, width: 860, height: 360)
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

    startStopButton.image = NSImage(
      systemSymbolName: state.startStopButtonMode == .start ? "play.fill" : "stop.fill",
      accessibilityDescription: nil
    )
    startStopButton.toolTip = state.startStopButtonMode == .start
      ? String(localized: "startSession")
      : String(localized: "stopSession")

    scoreLabel.attributedText = state.scoreText.flatMap { NSAttributedString($0) }
    scoreLabel.isHidden = state.isScoreLabelHidden

    accuracyRing.doubleValue = Double(state.accuracy)
    accuracyRing.setColor(Color.color(for: Double(state.accuracy)))
    accuracyRingButton.isEnabled = state.isAccuracyRingEnabled

    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    accuracyLabel.text = formatter.string(from: NSNumber(floatLiteral: Double(state.accuracy)))
    accuracyLabel.textColor = Color.color(for: Double(state.accuracy))

    NSApplication.shared.setWindowsNeedUpdate(true)
  }
}

// MARK: - NSToolbarDelegate

extension AppDelegate: NSToolbarDelegate {
  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .firstLevelButton,
      .randomLevelButton,
      .previousLevelButton,
      .nextLevelButton,
      .configureLevelButton,
      .startStopSessionButton,
      .repeatButton,
      .scoreLabel,
      .accuracyButton
    ]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .firstLevelButton,
      .randomLevelButton,
      .previousLevelButton,
      .nextLevelButton,
      .configureLevelButton,
      .startStopSessionButton,
      .repeatButton,
      .scoreLabel,
      .accuracyButton
    ]
  }

  func toolbar(
    _ toolbar: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar flag: Bool
  ) -> NSToolbarItem? {
    switch itemIdentifier {
    case .firstLevelButton:
      let item = NSToolbarItem(itemIdentifier: .firstLevelButton)
      item.toolTip = String(localized: "goToCMajor")
      item.image = NSImage(systemSymbolName: "c.circle.fill", accessibilityDescription: nil)
      item.action = #selector(firstLevelButtonTapped)
      item.target = self
      item.isEnabled = isToolbarItemEnabled[.firstLevelButton] ?? false

      return item

    case .randomLevelButton:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.toolTip = String(localized: "goToRandomLevel")
      item.image = NSImage(systemSymbolName: "shuffle.circle.fill", accessibilityDescription: nil)
      item.action = #selector(randomLevelButtonTapped)
      item.target = self
      item.isEnabled = true

      return item

    case .previousLevelButton:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.toolTip = String(localized: "goToPreviousLevel")
      item.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)
      item.action = #selector(previousLevelButtonTapped)
      item.target = self
      item.isEnabled = true

      return item

    case .nextLevelButton:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.toolTip = String(localized: "goToNextLevel")
      item.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
      item.isEnabled = true
      item.action = #selector(nextLevelButtonTapped)
      item.target = self

      return item

    case .configureLevelButton:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.toolTip = String(localized: "configureLevel")
      item.image = NSImage(systemSymbolName: "slider.vertical.3", accessibilityDescription: nil)
      item.isEnabled = true
      item.action = #selector(configureLevelButtonTapped)
      item.target = self

      return item

    case .startStopSessionButton:
      return startStopButton

    case .repeatButton:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.toolTip = String(localized: "replayQuestion")
      item.image = NSImage(systemSymbolName: "repeat", accessibilityDescription: nil)
      item.isEnabled = true
      item.action = #selector(repeatButtonTapped)
      item.target = self

      return item

    case .scoreLabel:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.toolTip = String(localized: "yourScore")
      item.view = scoreLabel

      return item

    case .accuracyButton:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.toolTip = String(localized: "lookAtStats")
      item.view = accuracyView
      item.isEnabled = true

      return item

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
