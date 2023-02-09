//
//  RRValues.swift
//  CHAMarathonHRV
//
//  Created by Alex Cruikshank on 1/22/23.
//

import Foundation

class RRValues: RingBuffer<UInt16> {
  func mean() -> Double {
    return data.reduce(0.0) { $0 + Double($1) } / Double(data.count)
  }
  
  func variance() -> Double {
    let u = mean()
    return data.reduce(0.0) { $0 + pow(u - Double($1), 2) } / Double(data.count)
  }
  
  func standardDeviation() -> Double {
    return sqrt(variance())
  }
}
