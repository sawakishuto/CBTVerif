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
    var transferCharacteristic: CBMutableCharacteristic?
    var peripheralPublisher = PassthroughSubject<String, Never>()

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Peripheral is powered on")
            setupService()
            startAdvertising()
        } else {
            print("Peripheral state: \(peripheral.state.rawValue)")
        }
    }

    func setupService() {
        transferCharacteristic = CBMutableCharacteristic(
            type: CBUUID(string: "180D"),
            properties: [.read],
            value: nil,
            permissions: [.readable]
        )

        let service = CBMutableService(type: CBUUID(string: "180A"), primary: true)
        service.characteristics = [transferCharacteristic!]

        peripheralManager?.add(service)
    }

    func startAdvertising() {
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: "Device",
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "180A")]
        ]
        peripheralManager?.startAdvertising(advertisementData)
        peripheralPublisher.send("Peripheral started advertising")
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
        centralManager?.scanForPeripherals(withServices: [CBUUID(string: "180A")], options: nil)
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        let deviceName = peripheral.name ?? "Unknown Device"
        print("Discovered peripheral: \(deviceName)")
        centralPublisher.send("Discovered peripheral: \(deviceName)")
    }

    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverServices error: Error?
    ) {
        if let services = peripheral.services {
            for service in services {
                print("Discovered Service: \(service.uuid)")
                centralPublisher.send("Discovered Service: \(service.uuid)")
                if service.uuid == CBUUID(string: "180A") {
                    peripheral.discoverCharacteristics([CBUUID(string: "180D")], for: service)

                }
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "180D") {
                    print("Discovered Characteristic: \(characteristic.uuid)")
                    centralPublisher.send("Discovered Characteristics")
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic, error: Error?
    ) {
        centralPublisher.send("readValue")
        if let value = characteristic.value {
            let receivedString = String(data: value, encoding: .utf8) ?? "Invalid data"
            print("Received from Peripheral: \(receivedString)")
            centralPublisher.send(receivedString)
        }
    }
}
