//
//  Resource.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation

// MARK:- EndPoint

protocol EndPoint {
  var base: String {get}
  var path: String {get}
  var parameters: [String: String] {get set}
  var headers: [String: String] {get set}
}

extension EndPoint {
  var parameters: [String: String] {
    get {
      return [:]
    }
    set {}
  }
  var headers: [String: String] {
    get {
      return [:]
    }
    set {}
  }
}

// MARK:- Resource

struct Resource<A> {
  let endPoint: EndPoint
}

extension Resource {
  var request: URLRequest {
    var components = URLComponents(string: endPoint.base)!
    components.path = endPoint.path
    if !endPoint.parameters.isEmpty {
      components.queryItems = [URLQueryItem]()
      endPoint.parameters.forEach { (key, value) in
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
      }
    }
    var request = URLRequest(url: components.url!)
    if !endPoint.headers.isEmpty {
      endPoint.headers.forEach({ (key, value) in
        request.setValue(key, forHTTPHeaderField: value)
        request.setValue(key, forHTTPHeaderField: value)
      })
    }
    return request
  }
}
