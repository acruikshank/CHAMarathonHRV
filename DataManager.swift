//
//  DataManager.swift
//  CHAMarathonHRV
//
//  Created by Alex Cruikshank on 1/21/23.
//

import Foundation
import HealthKit
import CoreBluetooth
import CryptoSwift

class DataManager: NSObject, ObservableObject {
  private var centralManager: CBCentralManager!
  private var heartMonitorPeriperal: CBPeripheral!
  private var txCharacteristic: CBCharacteristic!
  private var measureCharacteristic: CBCharacteristic!
  private var notifyCharacteristic: CBCharacteristic!
  private var peripheralArray: [CBPeripheral] = []
  private var rrArray = RRValues(size: 20)
  private var timer = Timer()
  
  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func connectToDevice() -> Void {
    centralManager?.connect(heartMonitorPeriperal!, options: nil)
  }
  
  func disconnectFromDevice() -> Void {
    guard let peripheral = heartMonitorPeriperal else { return }
    centralManager?.cancelPeripheralConnection(peripheral)
  }
  
  func removeArrayData() -> Void {
    centralManager.cancelPeripheralConnection(heartMonitorPeriperal)
    rrArray.removeAll()
    peripheralArray.removeAll()
  }
  
  func startScanning() -> Void {
    // Remove prior data
    print("start scanning...")
    peripheralArray.removeAll()
    rrArray.removeAll()
    // Start Scanning
    centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in
      self.stopScanning()
    }
  }
  
  func scanForBLEDevices() -> Void {
    // Remove prior data
    peripheralArray.removeAll()
    rrArray.removeAll()
    // Start Scanning
    centralManager?.scanForPeripherals(withServices: [] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    NSLog("Scanning...")
    
    Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in
      self.stopScanning()
    }
  }
  
  func stopTimer() -> Void {
    // Stops Timer
    self.timer.invalidate()
  }
  
  func stopScanning() -> Void {
    centralManager?.stopScan()
  }
  
  func delayedConnection() -> Void {
    BlePeripheral.connectedPeripheral = heartMonitorPeriperal
  }
  /*
   let healthStore = HKHealthStore()
   
   // Request authorization to access Healthkit.
   func requestAuthorization() {
   
   // The quantity types to read from the health store.
   let typesToRead: Set = [
   HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
   ]
   
   guard let heartVariabiltyType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
   // This should never fail when using a defined constant.
   fatalError("*** Unable to get the heart rate variability type ***")
   }
   
   let query = HKObserverQuery(sampleType: heartVariabiltyType, predicate: nil) { (query, completionHandler, errorOrNil) in
   if let error = errorOrNil {
   NSLog("Error initiating heart variabilty query: \(error)")
   return
   }
   
   let sortDescriptor = NSSortDescriptor(
   key: HKSampleSortIdentifierEndDate,
   ascending: false)
   self.healthStore.execute(HKSampleQuery(sampleType: heartVariabiltyType,
   predicate: nil,
   limit: 10,
   sortDescriptors: [sortDescriptor]) { (query, samples, errorOrNil) in
   
   if let error = errorOrNil {
   NSLog("Error making heart variabilty query: \(error)")
   return
   }
   
   guard let allSamples = samples else { return }
   NSLog("Last 10 samples")
   for sample in allSamples {
   guard let sample = sample as? HKQuantitySample else { return }
   NSLog("Got Sample \(sample.startDate): \(sample.quantity)")
   }
   })
   
   //      completionHandler()
   }
   
   // Request authorization for those quantity types
   healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
   NSLog("Authorization requested: ", success ? "success" : "failure")
   
   if (success) {
   self.healthStore.execute(query)
   }
   }
   }
   */
}

// MARK: - CBCentralManagerDelegate
// A protocol that provides updates for the discovery and management of peripheral devices.
extension DataManager: CBCentralManagerDelegate {
  
  // MARK: - Check
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
    switch central.state {
    case .poweredOff:
      print("Is Powered Off.")
    case .poweredOn:
      print("Is Powered On.")
//      startScanning()
      scanForBLEDevices()
    case .unsupported:
      print("Is Unsupported.")
    case .unauthorized:
      print("Is Unauthorized.")
    case .unknown:
      print("Unknown")
    case .resetting:
      print("Resetting")
    @unknown default:
      print("Error")
    }
  }
  
  // MARK: - Discover
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
    if peripheralArray.contains(peripheral) {
      return
    }

    if (peripheral.name != "Insight2 (A3D20369)") {
      return
    }
    print("Peripheral Discovered: \(peripheral.name)")

    heartMonitorPeriperal = peripheral
    

    peripheralArray.append(peripheral)
    heartMonitorPeriperal.delegate = self
    connectToDevice()
  }
  
  // MARK: - Connect
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    stopScanning()
    heartMonitorPeriperal.discoverServices(nil)
  }
}

// MARK: - CBPeripheralDelegate
// A protocol that provides updates on the use of a peripheral’s services.
extension DataManager: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    
    guard let services = peripheral.services else { return }
    for service in services {
      print("\(peripheral.identifier) has service \(service) uuid: \(service.uuid.uuidString)")
      if service.uuid == CBUUIDs.BLEService_UUID {
        peripheral.discoverCharacteristics(nil, for: service)
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else {
      return
    }
    
    print("Found \(characteristics.count) characteristics for service \(service).")
    
    for characteristic in characteristics {
      let props = CBCharacteristicProperties(rawValue: characteristic.properties.rawValue)
      print("Charactieristic: \(characteristic.uuid) \(characteristic.properties.rawValue)")
      if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_hrMeasure)  {
        
        notifyCharacteristic = characteristic

//        BlePeripheral.connectedRXChar = characteristic
        
        peripheral.setNotifyValue(true, for: characteristic)
//        peripheral.readValue(for: measureCharacteristic)
        
        print("Notify Characteristic: \(characteristic.uuid)")
//        return
      }
//      if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_hrMeasure)  {
//
//        measureCharacteristic = characteristic
//
//        BlePeripheral.connectedRXChar = measureCharacteristic
//
//        print("Measure Characteristic: \(measureCharacteristic.uuid)")
////        return
//      }
    }
//    delayedConnection()
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard error == nil else {
      print("Error getting characteristic value \(error)")
      return
    }

    if (characteristic == notifyCharacteristic) {
      guard let characteristicValue = notifyCharacteristic.value else { return }
      
      let ssn = "A3D20369"
      let sn = ssn.suffix(4).map({$0.asciiValue ?? 0 })
      let aesKey: Array<UInt8> = [sn[3], 0, sn[2], 21, sn[1], 0, sn[0], 12, sn[1], 0, sn[2], 68, sn[3], 0, sn[2], 88]
      let aes = try! AES(key: aesKey, blockMode: ECB(), padding: .noPadding)
      
      let tmpData = characteristicValue.subdata(in: 2..<18)
      let decrypted = try! aes.decrypt(tmpData.bytes)
      print("\(characteristicValue[0..<2].bytes) \(decrypted)")
    }

//    for i in stride(from: 2, to: characteristicValue.count, by:2) {
//      var value: UInt16 = UInt16(characteristicValue[i+1])
//      value <<= 8
//      value |= UInt16(characteristicValue[i])
//      rrArray.append(value: value)
//    }
//    print("HRV SDNN: \(rrArray.standardDeviation())")
  }
  
  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    peripheral.readRSSI()
  }
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    guard error == nil else {
      print("Error discovering services: error")
      return
    }
    print("Function: \(#function),Line: \(#line)")
    print("Message sent")
  }
  
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    print("*******************************************************")
    print("Function: \(#function),Line: \(#line)")
    if (error != nil) {
      print("Error changing notification state:\(String(describing: error?.localizedDescription))")
      
    } else {
      print("Characteristic's value subscribed")
    }
    
    if (characteristic.isNotifying) {
      print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
    }
  }
  
}
