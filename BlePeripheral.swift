//
//  BlePeripheral.swift
//  CHAMarathonHRV
//
//  Created by Alex Cruikshank on 1/22/23.
//

import Foundation
import CoreBluetooth

class BlePeripheral {
 static var connectedPeripheral: CBPeripheral?
 static var connectedService: CBService?
 static var connectedTXChar: CBCharacteristic?
 static var connectedRXChar: CBCharacteristic?
}
