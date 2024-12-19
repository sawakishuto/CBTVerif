//
//  ContentView.swift
//  CoreBlueToothVerification
//
//  Created by 澤木柊斗 on 2024/12/18.
//

import SwiftUI
import Combine


struct CBTthVerificationView: View {
    @StateObject var cBTVM = CBTthVerificationViewModel()
    
    var body: some View {
        VStack {
            List(cBTVM.RecievedData) {
                Text($0.dataString)
                    .fontWeight(.bold)
            }
            .backgroundStyle(.gray)
            Button {
                print(cBTVM.RecievedData)
            } label: {
                Text("データを更新する")
            }

        }
        .padding()
    }
}

#Preview {
    CBTthVerificationView()
}
