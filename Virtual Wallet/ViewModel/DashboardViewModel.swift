//
//  DashboardViewModel.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation

class DashboardViewModel {
  let offset: Float = 100
  var entries: Box<[Float]> = Box([])
  var max: Float = 0.0
  var min: Float = 0.0
  var change: Float = 0.0
  var btcUSD: Float = 0.0
  
  init() {
    self.loadData()
  }
}

fileprivate extension DashboardViewModel {
  
  func loadData() {
    BlockChainService.shared.loadCurrencyData() { btcUSD in
      self.btcUSD = btcUSD
      
      BlockChainService.shared.loadHistoricalEntriesData { chartModel in
        guard let model = chartModel else {
          return
        }
        if let max = model.values.map({ $0.value }).max() {
          self.max = max
        }
        if let min = model.values.map({ $0.value }).min() {
          self.min = min
        }
        
        if (model.values.count - 1) < model.values.count {
          let change = ((btcUSD - model.values[(model.values.count - 1)].value) / 100.0)
          self.change = change
        }
        
        let entries = self.generateEntries(from: model)
        self.entries.value = entries
      }
    }
  }
  
  func generateEntries(from model: ChartEntryModel) -> [Float] {
    if let min = model.values.map({ $0.value }).min() {
      return Array(model.values.enumerated().map({ (i, elem) in
        return (elem.value - min + offset)
      }))
    }
    return []
  }
}
