//
//  MainTabBarController.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import UIKit

protocol MainTabBarControllerDelegate: Coordinator {
  func previous()
}

class MainTabBarController: UITabBarController {
  weak var coordinatorDelegate: MainTabBarControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /// self.tabBar.unselectedItemTintColor = .white
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
