//
//  SigninNavigationController.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 18/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation
import UIKit

protocol LoginNavigationControllerDelegate: Coordinator {
  func next()
}

class LoginNavigationController: SPNativeLoginNavigationController {
  
  private var viewModel = LoginNavigationViewModel()
  weak var coordinatorDelegate: LoginNavigationControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationBar.barStyle = .blackTranslucent
    self.navigationBar.tintColor = .white
    self.navigationBar.barTintColor = #colorLiteral(red: 0.3058823529, green: 0.5647058824, blue: 0.737254902, alpha: 1)
  }
  
  //Mark: - Actions
  override func login(with login: String, password: String, completion: @escaping (SPOauthState) -> ()) {
    viewModel.login(with: login, password: password) { (success) in
      guard success else {
        completion(.error)
        return
      }
      completion(.success)
      self.coordinatorDelegate?.next()
    }
  }
  
  override func newLogin(with username: String, login: String, password: String, confirmPassword: String, completion: @escaping (SPOauthState) -> ()) {
    guard viewModel.isValidPasswords(password, and: confirmPassword) else {
      completion(.invalidPasswordMatch)
      return
    }
    viewModel.newLogin(with: username, login: login, password: password, confirmPassword: confirmPassword) { (success) in
      guard success else {
        completion(.error)
        return
      }
      completion(.success)
      self.coordinatorDelegate?.next()
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
