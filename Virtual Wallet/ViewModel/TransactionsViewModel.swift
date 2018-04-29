//
//  TransactionsViewModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation

class TransactionsViewModel {
  var content: Box<[TransactionModel]> = Box([])
  
  func load() {
    UserService.shared.currentUser.bind { (user) in
      self.content.value = user.transactions
    }
  }
}
