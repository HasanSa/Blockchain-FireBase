//
//  CurrencyModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation

struct CurrencyModel: Codable {
  var USD: USDModel
  
  struct USDModel: Codable {
    var last: Float
  }
}
