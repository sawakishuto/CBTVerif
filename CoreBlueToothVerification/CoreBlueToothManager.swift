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

