//
//  Box.swift
//  QuranSpeechApp
//
//  Created by Hasan Sa on 16/09/2017.
//  Copyright © 2017 Quran Speech Team. All rights reserved.
//

import Foundation

class Box<T> {
  typealias Listener =  (T) -> Void
  var listener: Listener?
  private var queue: DispatchQueue
  
  var value: T? = nil {
    didSet {
      if let val = value {
        queue.async {
          self.listener?(val)
        }
      }
    }
  }
  
  init(_ value: T?, queue: DispatchQueue = DispatchQueue.main) {
    self.value = value
    self.queue = queue
  }
  
  func bind(listener: Listener?) {
    self.listener = listener
    if let value = self.value {
      listener?(value)
    }
  }
}
