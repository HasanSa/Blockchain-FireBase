//
//  ChartModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 18/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import UIKit

struct ChartEntryModel: Codable {
  fileprivate var bpi: [String: Double] = [:]
  fileprivate var disclaimer: String?
  
  struct Price {
    var date: Date
    var value: Float
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let nodes = try? container.decode([String: Double].self, forKey: .bpi) {
      self.bpi = nodes
    }
    if let disclaimer = try? container.decode(String.self, forKey: .disclaimer) {
      self.disclaimer = disclaimer
    }
  }
}

extension ChartEntryModel {
  var values: [Price] {
    var bpi: [Price] = self.bpi.keys.map({
      // 2018-03-20
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      formatter.locale = Locale(identifier: "en_US_POSIX")
      return Price.init(date: formatter.date(from: $0)!, value: Float("\(self.bpi[$0]!)")!)
    })
    bpi.sort { (model1, model2) in
      return model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970
    }
    return bpi
  }
}
