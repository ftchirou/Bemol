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

  // MARK: -

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

  static func main() {
    let delegate = AppDelegate()
    NSApplication.shared.delegate = delegate

    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
  }

  // MARK: - Lifecycle

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    window = NSWindow(contentViewController: rootViewController())
    window?.appearance = NSAppearance(named: .vibrantDark)
    window?.title = String(localized: "bemol")
    window?.isReleasedWhenClosed = true
    window?.styleMask.formUnion(.borderless)
    window?.styleMask.remove(.resizable)
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
    viewController.view.frame = NSRect(x: 0, y: 0, width: 860, height: 420)
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
  }
}
