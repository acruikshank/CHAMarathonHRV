//
//  CBUUIDs.swift
//  Basic Chat MVC
//
//  Created by Trevor Beaton on 2/3/21.
//
import Foundation
import CoreBluetooth

struct CBUUIDs{

  static let kBLEService_HRV_UUID = "180D"
//  static let kBLEService_Insight_UUID = "81072F40-9F3D-11E3-A9DC-0002A5D5C51B"
//  static let kBLEService_Insight_UUID = "180A"
  static let kBLE_Characteristic_uuid_hrMeasure = "2A37"
//    static let kBLE_Characteristic_uuid_eegNotify = "81072F41-9F3D-11E3-A9DC-0002A5D5C51B"
//  static let kBLE_Characteristic_uuid_eegNotify = "81072F43-9F3D-11E3-A9DC-0002A5D5C51B"
//  static let kBLE_Characteristic_uuid_eegRead = "81072F44-9F3D-11E3-A9DC-0002A5D5C51B"

  static let BLEService_UUID = CBUUID(string: kBLEService_HRV_UUID)
  static let BLE_Characteristic_uuid_hrMeasure = CBUUID(string: kBLE_Characteristic_uuid_hrMeasure)
//  static let BLE_Characteristic_uuid_eegNotify = CBUUID(string: kBLE_Characteristic_uuid_eegNotify)
//  static let BLE_Characteristic_uuid_eegRead = CBUUID(string: kBLE_Characteristic_uuid_eegRead)
}
