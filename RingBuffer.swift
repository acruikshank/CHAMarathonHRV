//
//  RingBuffer.swift
//  CHAMarathonHRV
//
//  Created by Alex Cruikshank on 1/22/23.
//

import Foundation

class RingBuffer<T> {
  var data = Array<T>()
  var next: Int = 0
  let size: Int
  
  init(size: Int) {
    self.size = size
  }
  
  func append(value: T) {
    if data.count < size {
      data.append(value)
      return
    }
    
    data[next] = value
    next = (next + 1) % size
  }
  
  func removeAll() {
    data.removeAll()
    next = 0
  }
  
  subscript(index: Int) -> T {
      get {
          return data[index % size]
      }
      set(newValue) {
          data[index % size] = newValue
      }
  }
}
