//
//  SendViewModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation

class SendViewModel {
  
  func sendTransaction(to address: String, quantity: Float, completion: @escaping (Bool) -> ()) {
    guard let user = UserService.shared.currentUser.value, quantity > 0, quantity < user.totalBalance   else {
      completion(false)
      return
    }
    BlockChainService.shared.balance(of: address) { (value) in
      guard value != nil else {
        completion(false)
        return
      }
      BlockChainService.shared.sendPayment(with: user.guid, amount: quantity, to: address) { dict in
        guard let dict = dict else {
          completion(false)
          return
        }
        print(dict)
        completion(true)
      }
    }

  }
}
