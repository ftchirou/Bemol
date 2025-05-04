///
/// SessionDelegate.swift
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
import os
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // MARK: -

  private lazy var environment = AppEnvironment(
    notePlayer: MIDINotePlayer(),
    practiceManager: CyclicPracticeManager(
      storage: FileSessionStorage(fileManager: .default),
      levelGenerator: DiatonicLevelGenerator(),
      noteResolutionGenerator: DiatonicNoteResolutionGenerator(),
      preferences: UserDefaults.standard
    ),
    logger: Logger()
  )

  private lazy var loop: AppLoop = AppLoop(
    environment: environment,
    initialState: AppState()
  )

  private lazy var app = App(
    environment: environment,
    loop: loop
  )

  // MARK: -

  var window: UIWindow?

  // MARK: - Lifecycle

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let scene = (scene as? UIWindowScene) else { return }


    window = UIWindow(frame: scene.screen.bounds)
    window?.backgroundColor = .black
    window?.makeKeyAndVisible()

    scene.requestGeometryUpdate(.iOS(interfaceOrientations: [.landscape]))

    window?.windowScene = scene
  }

  func sceneDidDisconnect(_ scene: UIScene) {}

  func sceneDidBecomeActive(_ scene: UIScene) {
    if window?.rootViewController == nil {
      window?.rootViewController = rootViewController()
      loop.delegate = AppLoopDelegate(
        didUpdateState: { [weak self] in self?.didUpdateState($0) }
      )
      loop.dispatch(.didLoad)
    }
  }

  func sceneWillResignActive(_ scene: UIScene) {}

  func sceneWillEnterForeground(_ scene: UIScene) {}

  func sceneDidEnterBackground(_ scene: UIScene) {}

  // MARK: - Private Helpers

  private func rootViewController() -> UIViewController {
    app.view.translatesAutoresizingMaskIntoConstraints = false

    let viewController = UIViewController()
    viewController.view.backgroundColor = .black
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

extension SceneDelegate {
  func didUpdateState(_ state: AppState) {
    app.setState(state)
  }
}
