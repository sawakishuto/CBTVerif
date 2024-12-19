//
//  PeripheralManager.swift
//  CoreBlueToothVerification
//
//  Created by 澤木柊斗 on 2024/12/18.
//

import Combine
import CoreBluetooth
import Foundation

class PeripheralManager: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var peripheralPublisher = PassthroughSubject<String, Never>()

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Peripheral is powered on")
            startAdvertising()
        } else {
            print("Peripheral state: \(peripheral.state.rawValue)")
        }
    }

    func startAdvertising() {
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: "Device",
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "1234")],
            CBAdvertisementDataManufacturerDataKey: "Hello".data(using: .utf8)!
        ]
        print(advertisementData)
        peripheralManager?.startAdvertising(advertisementData)
        peripheralPublisher.send("Peripheral is powered on")
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed to start advertising: \(error.localizedDescription)")
        } else {
            print("Advertising started successfully.")
        }
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest
    ) {
        if request.characteristic.uuid == transferCharacteristic?.uuid {
            request.value = "UidIs1234".data(using: .utf8)
            peripheralManager?.respond(to: request, withResult: .success)
            peripheralPublisher.send("Respond Req")
        } else {
        }
    }
}

class CentralManager: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager?
    var centralPublisher = PassthroughSubject<String, Never>()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Central is powered on")
            centralPublisher.send("Central is powered on")
            startScanning()
        } else {
            print("Central state: \(central.state.rawValue)")
        }
    }

    func startScanning() {
        centralManager?.scanForPeripherals(withServices:  [CBUUID(string: "1234")], options: nil)
    }


    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let dataString = String(data: manufacturerData, encoding: .utf8) ?? "Invalid Data"
            print("Received data: \(dataString)")
            centralPublisher.send("Received data: \(dataString)")
        } else {
            centralPublisher.send("manufacturerData is invalid data")
        }
    }
}
