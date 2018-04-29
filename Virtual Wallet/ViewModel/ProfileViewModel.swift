//
//  ProfileViewModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation

class ProfileViewModel {
  
  var user: Box<UserModel> = Box(nil)
  
  var balances: Box<[String: Float]> = Box([:])
  var values: [String: Float] = [:]
  
  func load() {
    UserService.shared.currentUser.bind { (user) in
      self.user.value = user
      self.getBalances(of: user.allAddresses) {
        self.balances.value = self.values
      }
      
    }
  }
  
  func add(address: String, callback: @escaping ( (Bool) -> Void)) {
    if var user = self.user.value {
      user.addresses[address] = address
      self.getBalances(of: user.allAddresses) {
        let success = self.values[address] != nil
        if success {
          self.balances.value = self.values
          user.totalBalance = self.values.reduce(into: 0, { $0 += $1.value })
          self.user.value = user
          UserService.shared.currentUser = self.user
        }
        callback(success)
      }
    }
  }
  
  func logout() {
    UserService.shared.logout()
  }
}

extension ProfileViewModel {
  func getBalances(of addresses:  [String], start: Int = 0, callback: @escaping ( () -> Void)) {
    guard start < addresses.count else {
      callback()
      return
    }
    let address = addresses[start]
    BlockChainService.shared.balance(of: address) { (res) in
      if let res = res {
        self.values[address] = res
      }
      self.getBalances(of: addresses, start: start + 1, callback: callback)
    }
  }
}
