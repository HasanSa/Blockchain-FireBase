//
//  LoginNavigationViewModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation

class LoginNavigationViewModel {
  func login(with login: String, password: String, completion: @escaping (Bool) -> ()) {
    UserService.shared.login(email: login, password: password) { (success, error) in
      if success  {
        BlockChainService.shared.updateMainPassKey(password)
      }
      completion(success)
    }
  }
  
  func isValidPasswords(_ password: String, and confirm: String) -> Bool {
    return password == confirm
  }
  
  func newLogin(with username: String, login: String, password: String, confirmPassword: String, completion: @escaping (Bool) -> ()) {
    BlockChainService.shared.createUser(password: password) { (userModel) in
      guard let user = userModel else {
        completion(false)
        return
      }
      UserService.shared.create(username: username, email: login, password: password, user: user, completion: { (success) in
        if success  {
          BlockChainService.shared.updateMainPassKey(password)
        }
        completion(success)
      })
    }
  }
}
