//
//  BlockChainService.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//


import Foundation

// MARK:- BlockChainService
class WebService {
  func load<A: Codable>(resource: Resource<A>, callback: @escaping (A?, Any?) -> Void) {
    URLSession.shared.dataTask(with: resource.request) { (data, response, error) in
      guard error == nil, let data = data else {
        print(error!)
        callback(nil, nil)
        return
      }
      do {
        let result = try JSONDecoder().decode(A.self, from: data)
        callback(result, nil)
      } catch {
        if let urlresponse = response as? HTTPURLResponse, urlresponse.statusCode == 200 ,let text = String(data: data, encoding: .utf8) {
            callback(nil, text)
        } else {
          print(error)
          callback(nil, nil)
        }
        
      }
      }.resume()
  }
}

class BlockChainService: WebService {
  
  fileprivate static let MainPassKey = "BlockChainServicePassKey"
  fileprivate static let Satoshi = Float(100_000_000)
  fileprivate struct Endpoints {
    
    enum URLs: String {
      case blockchainInfoAPI = "https://api.blockchain.info"
      case blockchainInfo = "https://blockchain.info"
      case coindesk = "https://api.coindesk.com"
      case localhost = "https://young-earwig-34.localtunnel.me" // "http://localhost:3000"
    }
    
    struct Charts: EndPoint {
      var base = URLs.coindesk.rawValue
      var path = "/v1/bpi/historical/close.json"
    }
    struct Ticker: EndPoint {
      var base = URLs.blockchainInfo.rawValue
      var path = "/ticker"
    }
    struct Create: EndPoint {
      var base = URLs.localhost.rawValue
      var path = "/api/v2/create"
      var parameters: [String : String] = ["api_code": Config.apiKey]
    }
    struct Merchant: EndPoint {
      var base = URLs.localhost.rawValue
      var path = "/merchant"
      var parameters: [String : String] = ["password": Config.apiKey]
    }
    struct AddressBalance: EndPoint {
      var base = URLs.blockchainInfo.rawValue
      var path = "/q/addressbalance"
      var parameters: [String : String] = ["password": Config.apiKey]
    }
  }
  
  static let shared = BlockChainService()
  
  var btcUSD: Float = 0.0
  
  fileprivate var mainPassKey: String {
    if let pass = UserDefaults.standard.value(forKey: BlockChainService.MainPassKey) as? String,
      let trs = pass.base64Decoded() {
      return trs
    }
    return ""
  }
  
  func updateMainPassKey(_ key: String) {
    if let base64Str = key.base64Encoded() {
      UserDefaults.standard.set(base64Str, forKey: BlockChainService.MainPassKey)
    }
  }
  
  func createUser(password: String, callback: @escaping (UserModel?) -> Void) {
    var create = Endpoints.Create()
    create.parameters["password"] = password
    load(resource: Resource<UserModel>(endPoint: create)) { model, _ in
      callback(model)
    }
  }
  
  func balance(of address: String, callback: @escaping (Float?) -> Void) {
    var balanceEndPoint = Endpoints.AddressBalance()
    balanceEndPoint.path += "/\(address)"
    load(resource: Resource<Float>(endPoint: balanceEndPoint)) { _, value in
      var result: Float? = nil
      if let res = value as? String, let fl = Float(res) {
        result = (fl / BlockChainService.Satoshi)
      }
      callback(result)
    }
  }
  
  func sendPayment(with guid: String, amount: Float, to: String, callback: @escaping ([String: String]?) -> Void) {
    var sendPaymentEndPoint = Endpoints.Merchant()
    sendPaymentEndPoint.path += "/\(guid)/payment"
    sendPaymentEndPoint.parameters["password"] = mainPassKey
    sendPaymentEndPoint.parameters["amount"] = "\(amount * BlockChainService.Satoshi)"
    sendPaymentEndPoint.parameters["to"] = to
    load(resource: Resource<[String: String]>(endPoint: sendPaymentEndPoint)) { model, _ in
      callback(model)
    }
  }
  
  
  func loadCurrencyData(callback: @escaping (Float) -> Void) {
    load(resource: Resource<CurrencyModel>(endPoint: Endpoints.Ticker())) { model, _ in
      let last = model?.USD.last ?? 0.0
      callback(last)
      self.btcUSD = last
    }
  }
  
  func loadHistoricalEntriesData(_ callback: @escaping (ChartEntryModel?) -> Void) {
    load(resource: Resource<ChartEntryModel>(endPoint: Endpoints.Charts())) { model, _ in
      callback(model)
    }
  }
}
