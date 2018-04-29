//
//  AppCoordinator.swift
//  MVVM-C
//
//  Created by Scotty on 19/05/2016.
//  Copyright © 2016 Streambyte Limited. All rights reserved.
//

import UIKit

protocol Coordinator: class {
  func start()
}

class AppCoordinator: Coordinator {
  
  var window: UIWindow
  
  init(window: UIWindow) {
    self.window = window
  }
  
  func start() {
    if UserService.shared.isLoggedIn {
      showMain()
    } else {
      showLogin()
    }
  }
}

fileprivate extension AppCoordinator {
  func showLogin() {
    let loginNavigationController = LoginNavigationController()
    loginNavigationController.coordinatorDelegate = self
    window.rootViewController = loginNavigationController
  }
  
  func showMain() {
    let mainViewController = UIStoryboard.init(name: "Main",
                                               bundle: nil)
      .instantiateInitialViewController() as! MainTabBarController
    mainViewController.coordinatorDelegate = self
    mainViewController.selectedIndex = 1
    window.rootViewController = mainViewController
  }
}


// MARK: - LoginNavigationControllerDelegate
extension AppCoordinator: LoginNavigationControllerDelegate {
  func next() {
    self.showMain()
  }
}

// MARK: - MainTabBarControllerDelegate
extension AppCoordinator: MainTabBarControllerDelegate {
  func previous() {
    self.showLogin()
  }
}
