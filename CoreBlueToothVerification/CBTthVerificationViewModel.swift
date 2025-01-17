//
//  CBTthVerificationViewModel.swift
//  CoreBlueToothVerification
//
//  Created by 澤木柊斗 on 2024/12/18.
//

import Foundation
import Combine


struct CBModel: Identifiable {
    let id = UUID().uuidString
    let dataString: String
}

class CBTthVerificationViewModel: ObservableObject {
    let peripheralManager = PeripheralManager()
    let centralManager = CentralManager()
    var cancellable = [AnyCancellable]()
    @Published var RecievedData = [CBModel]()

    init() {
        centralManager.centralPublisher.sink(receiveCompletion: { completion in
            print("complete")
        }, receiveValue: {
            self.RecievedData.append(CBModel(dataString: $0))
            }
        )
        .store(in: &cancellable)
        peripheralManager.peripheralPublisher.sink(receiveCompletion: { completion in
            print("complete")
        }, receiveValue: {
            self.RecievedData.append(CBModel(dataString: $0))
            }
        )
        .store(in: &cancellable)
    }

    func checkConnectedService() {
//        let connection =  centralManager.listConnectedPeripherals()
    }


}
