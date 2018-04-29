//
//  UserModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 18/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import UIKit

struct TransactionModel: Codable {
  var date: Float
  var quantity: Float
  var to: String?
  var from: String?
}

struct UserModel: Codable {
  var userId: String = ""
  var username: String = ""
  var address: String = ""
  var guid: String = ""
  var addresses: [String: String] = [:]
  var transactions: [TransactionModel] = []
  var totalBalance: Float = 0.0
  
  init() {}
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let userId = try? container.decode(String.self, forKey: .userId) {
      self.userId = userId
    }
    if let username = try? container.decode(String.self, forKey: .username) {
      self.username = username
    }
    if let address = try? container.decode(String.self, forKey: .address) {
      self.address = address
    }
    if let guid = try? container.decode(String.self, forKey: .guid) {
      self.guid = guid
    }
    if let addresses = try? container.decode([String: String].self, forKey: .addresses) {
      self.addresses = addresses
    }
    if let totalBalance = try? container.decode(Float.self, forKey: .totalBalance) {
      self.totalBalance = totalBalance
    }
    if var nodes = try? container.nestedUnkeyedContainer(forKey: .transactions) {
      var allTransactions: [TransactionModel] = []
      while !nodes.isAtEnd {
        if let node = try? nodes.decode(TransactionModel.self) {
          allTransactions += [node]
        }
      }
      self.transactions = allTransactions
    }
  }
}

extension UserModel {
  var allAddresses: [String] {
    var allAddresses: [String] = Array(addresses.keys)
    allAddresses.insert(address, at: 0)
    return allAddresses
  }
}
