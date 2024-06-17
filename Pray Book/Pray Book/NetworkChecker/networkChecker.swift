//
//  networkChecker.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-09.
//

import SwiftUI
import Network

//Monitor network connectivity
class NetworkMonitor: ObservableObject {
    @Published var isNotConnectedAlertPresented = false
    
    private let monitor = NWPathMonitor()
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isNotConnectedAlertPresented = (path.status != .satisfied)
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}
