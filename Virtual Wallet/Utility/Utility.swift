//
//  Utility.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation


extension String {
  //: ### Base64 encoding a string
  func base64Encoded() -> String? {
    if let data = self.data(using: .utf8) {
      return data.base64EncodedString()
    }
    return nil
  }
  
  //: ### Base64 decoding a string
  func base64Decoded() -> String? {
    if let data = Data(base64Encoded: self) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }
}
